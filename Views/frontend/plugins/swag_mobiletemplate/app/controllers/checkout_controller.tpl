<script type="text/javascript">
/**
 * @file checkout_controller.js
 * @link http://www.shopware.de
 * @author S.Pohl <stp@shopware.de>
 * @date 11-05-11
 */
Ext.regController('checkout', {

	/** Contains the payment methods */
	paymentMethods: null,

	/** Contains the current selected payment method */
	selectedMethod: null,

	/** Contains the object of the active view in the checkout section */
	view: null,

	/**
	 * Checks if the necessary parameter are passed and creates the
	 * view.
	 *
	 * This method represents the constructor of the controller
	 *
	 * @param options - Option object from the Ext.dispatch()
	 * @return void
	 */
	show: function(options) {

		/* Checkout needs parent view */
		if(!Ext.isDefined(options.parentView)) {
			throw Error('Checkout Controller needs parentView to add checkout view');
		}

		/** Create the needed view and show it */
		this.initView(options.parentView);

	},

	/**
	 * Creates the needed view for the checkout section.
	 * If the user isn't logged in the user will be
	 * redirected to a login / register page to login
	 * in the section
	 *
	 * @param  parentView
	 * @return view - the active view
	 */
	initView: function(parentView) {

		isUserLoggedIn = ~~isUserLoggedIn;

		if(!isUserLoggedIn) {
			this.view = this.openAccountView(parentView);
		} else {
			this.view = this.openCheckoutView(parentView);
		}

		/** Set view as the active item */
		parentView.setActiveItem(this.view, 'slide');

		return this.view;
	},

	/**
	 * Creates the account view and modifies
	 * the parent view
	 *
	 * @param parentView
	 * @return view
	 */
	openAccountView: function(parentView) {
		/** Create login form - TODO: Transform title to smarty snippet */
		this.view = new App.views.Account.index;
		this.view.toolbar.setTitle('Checkout');

		/** Update the parent view */
		parentView.add(this.view);
		parentView.toolbar.hide();
		parentView.doComponentLayout();

		/** Update the back button handler */
		this.view.backBtn.setHandler(function() {
			parentView.setActiveItem(0, {
				type: 'slide',
				reverse: true,
				scope: this
			});
		});
		/** Modify the back button and show it. TODO: Transform title to a smarty snippet */
		this.view.backBtn.setText('Warenkorb');
		this.view.backBtn.show();

		return this.view;
	},

	/**
	 * Creates the checkout view and modifies the
	 * parent view
	 *
	 * @param parentView
	 * @return view
	 */
	openCheckoutView: function(parentView) {

		parentView.setLoading(true);

		var view, methods = [],
			userData = App.stores.UserData.proxy.reader.rawData.sUserData,
			me = this, method;

		App.Helpers.getRequest(App.RequestURL.getPayment, '', function(data) {
			this.paymentMethods = data.sPaymentMethods;

			/** Create the payment methods */
			for(idx in data.sPaymentMethods) {
				var payItem = data.sPaymentMethods[idx];
				
				if(App.Helpers.inArray(payItem.id, payments)) {
					methods.push(new Ext.form.Radio({
						name: 'paymentMethod',
						value: payItem.id,
						label: payItem.description,
						checked: (userData.additional.payment.id == payItem.id) ? true : false,
						listeners: {
							scope: this,
							check: me.onPayment
						}
					}));

					/** Set the active payment */
					if(userData.additional.payment.id == payItem.id) {
						method = payItem;
					}
				}
			}

			/** Create the checkout view */
			this.view = new App.views.Checkout.index;
			this.view.paymentField.add(methods);

			/** If payment based on a iframe */
			this.selectedMethod = method;

			if(this.selectedMethod && this.selectedMethod.embediframe) {
				var url = this.selectedMethod.embediframe;
				this.view.submitOrderBtn.setText('Zahlung durchführen').setHandler(function() {

					if(Ext.isEmpty(Ext.getCmp('agbCheckbox').getValue())) {
						Ext.Msg.alert('{s name="MobileCheckoutError"}Fehler{/s}', '{s name="MobileCheckoutEmptyAGB"}Bitte best&auml;tigen Sie die AGB um Ihre Bestellung durchzuf&uuml;hren.{/s}');
						return false;
					}

					window.location.href = url;
				});
			}

			/** Update the parent view */
			parentView.add(this.view);
			parentView.setActiveItem(this.view, { type: 'slide' });
			parentView.toolbar.hide();
			parentView.doComponentLayout();
			parentView.setLoading(false);

			this.view.pnl.doLayout();

		});
	},

	/**
	 * Event handler
	 * @param chkbox
	 */
	onPayment: function(chkbox) {
		var me = this;

		/** Change the prefered payment method for the user (server side) */
		Ext.Ajax.request({
			url: App.RequestURL.changePayment,
			method: 'post',
			disableCaching: false,
			params: {
				'register[payment]': chkbox.getValue()
			}
		});

		/** Determine the actual payment method of the user */
		Ext.each(this.paymentMethods, function(el, i) {
			if(el.id == ~~chkbox.value) {
				me.selectedMethod = el;
			}
		});
		
		if(me.selectedMethod.embediframe) {
			var url = me.selectedMethod.embediframe;
			me.view.submitOrderBtn.setText('Zahlung durchführen').setHandler(function() {

				if(Ext.isEmpty(Ext.getCmp('checkoutForm').getValues().paymentMethod)) {
					Ext.Msg.alert('{s name="MobileCheckoutError"}Fehler{/s}', '{s name="MobileCheckoutEmptyPaymentMethod"}Bitte w&auml;hlen Sie eine Zahlungsart aus um Ihre Bestellung durchzuf&uuml;hren.{/s}');
					return false;
				}

				if(!Ext.getCmp('agbCheckbox').isChecked()) {
					Ext.Msg.alert('{s name="MobileCheckoutError"}Fehler{/s}', '{s name="MobileCheckoutEmptyAGB"}Bitte best&auml;tigen Sie die AGB um Ihre Bestellung durchzuf&uuml;hren.{/s}');
					return false;
				}

				window.location.href = url;
			});
		} else {
			me.view.submitOrderBtn.setText('Bestellung absenden').setHandler(function() {
				var pnl     = Ext.getCmp('orderPnl'),
					values  = pnl.getValues();

				if(Ext.isEmpty(Ext.getCmp('checkoutForm').getValues().paymentMethod)) {
					Ext.Msg.alert('{s name="MobileCheckoutError"}Fehler{/s}', '{s name="MobileCheckoutEmptyPaymentMethod"}Bitte w&auml;hlen Sie eine Zahlungsart aus um Ihre Bestellung durchzuf&uuml;hren.{/s}');
					return false;
				}

				if(!Ext.getCmp('agbCheckbox').isChecked()) {
					Ext.Msg.alert('{s name="MobileCheckoutError"}Fehler{/s}', '{s name="MobileCheckoutEmptyAGB"}Bitte best&auml;tigen Sie die AGB um Ihre Bestellung durchzuf&uuml;hren.{/s}');
					return false;
				}
				pnl.submit();
			});
		}
	},

	/**
	 * Deletes an articles from the basket and from
	 * the client side basket store
	 *
	 * @param options
	 * @return bool
	 */
	deleteItem: function(options) {
		var element = options.element, val;

		if(!Ext.isDefined(options.element)) {
			throw Error('Delete Item needs a element');
		}

		element = Ext.get(element);
		val = element.dom.attributes[1].nodeValue;
		App.stores.Cart.remove(val);

		return true;
	},

	/**
	 * Updates the summary display field
	 * in the cart list
	 *
	 * @param options
	 * @return bool
	 */
	updateSumDisplay: function(options) {
		var element, price;

		if(!Ext.isDefined(options.element)) {
			throw Error('UpdateSumDisplay needs the display element');
		}

		element = options.element;

		/** TODO: Use smarty snippet for the currency symbol */
		if(App.stores.Cart.amount && element) {
			price = App.Helpers.number_format((Math.round(App.stores.Cart.amount*100) / 100), 2, ',', '.') + '&nbsp;&euro;*';
			element.setHTML(price);
		}

		return true;
	},

	/**
	 * Processes the user's order on the client side and checks if the
	 * order was successfully processed.
	 *
	 * Note that this method doesn't send the ajax request to the server, it just
	 * provides the response to the user and slides to the start page of the template
	 *
	 * @param options
	 */
	processOrder: function(options) {

		if(!options.response.success) {
			Ext.Msg.alert('{s name="MobileCheckoutOrderFailedTitle"}Bestellung fehlgeschlagen{/s}', options.response.msg);
			return false
		}
		Ext.Msg.alert('Bestellung erfolgreich', options.response.msg, function() {
			var owner = options.owner;

			/* Clear cart store */
			App.stores.Cart.removeAll();

			/* Destroy Order confirmation */
			Ext.getCmp('orderConfirmation').destroy();

			/* Create new cart list on owner */
			owner.pnl.update('');
			owner.pnl.show();
			owner.toolbar.show();
			owner.doLayout();

			/* Hide checkout button */
			owner.checkoutBtn.hide();

			/* Slide to home view */
			Ext.getCmp('viewport').setActiveItem(0, {
				type: 'slide',
				reverse: true,
				scope: this
			});

			/* Refresh main view */
			Ext.getCmp('shop').toolBar.hide();
			Ext.getCmp('shop').doLayout();
			Ext.getCmp('shop').doComponentLayout();
			Ext.getCmp('shop').setActiveItem(Ext.getCmp('home'));
		});
		return true;
	}
});
</script>