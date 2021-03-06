{extends file="backend/index/parent.tpl"}

{block name="backend_index_body_inline"}
<link rel="stylesheet" media="screen, projection" href="{link file='backend/mobile_template/uploader/fileuploadfield.css'}" />
{include file="backend/mobile_template/styles.tpl"}

<script type="text/javascript" src="{link file='backend/mobile_template/uploader/FileUploadField.js'}"></script>
<script type="text/javascript">
Ext.ns('Shopware.SwagMobileTemplate');

(function() {
	Ext.QuickTips.init();
	View = Ext.extend(Ext.Viewport, {
	    layout: 'border',
	    initComponent: function() {
			var me = this;

			this.subShopStore = new Ext.data.JsonStore({
				url: '{url controller="MobileTemplate" action="getSubshopStore"}',
				storeId: 'subShopStore',
				root: 'data',
				idProperty: 'id',
				successProperty: 'success',
				totalProperty: 'totalCount',
				fields: [ 'id', 'valueField', 'displayText' ]
			});

			
			/** General settings form panel */
			this.generellPnl = new Ext.FormPanel({
				title: 'Grundkonfiguration',
				padding: 15,
				autoScroll: true,
				items: [{
					xtype: 'fieldset',
					anchor: '0',
					title: 'Grundkonfiguration',
					labelWidth: 250,
					items: [{
						// Supported devices
						xtype: 'checkboxgroup',
						fieldLabel: 'Unterst&uuml;tzte Ger&auml;te',
						name: 'supportedDevices',
						columns: 2,
						items: {$supportedDevicesJSON}
					}, {
						// Supported Paymentmeans
						xtype: 'checkboxgroup',
						fieldLabel: 'Unterst&uuml;tzte Zahlungsarten',
						name: 'supportedPaymentmeans',
						columns: 2,
						items: {$supportedPaymentmeansJSON}
					}, {
						// Shopsite ID AGB
						xtype: 'textfield',
						fieldLabel: 'Shopseiten-ID zu den AGB',
						width: 200,
						name: 'agbInfoID',
						value: '{$agbInfoID}'
					}, {
						// Shopsite ID Right of Cancelation
						xtype: 'textfield',
						fieldLabel: 'Shopseiten-ID zum Wiederrufsrecht',
						name: 'cancelRightID',
						width: 200,
						value: '{$cancelRightID}'
					}, {
						// Shopsite group name
						xtype: 'textfield',
						fieldLabel: 'Shopseiten-Gruppe',
						name: 'infoGroupName',
						width: 200,
						value: '{$infoGroupName}'
					}, {
						// Show Link to normal version of the shop
						xtype: 'checkbox',
						fieldLabel: 'Link zur normalen Ansicht',
						name: 'showNormalVersionLink',
						checked: {if $showNormalVersionLink}true{else}false{/if}
					}, {
						// Voucher on confirm page
						xtype: 'checkbox',
						fieldLabel: 'Gutscheineingabe auf der Bestellbest&auml;tigungsseite anzeigen',
						name: 'useVoucher',
						checked: {if $useVoucher}true{else}false{/if}
					}, {
						// Newsletter signup on confirm page
						xtype: 'checkbox',
						fieldLabel: 'Newsletter-Anmeldung auf der Bestellbest&auml;tigungsseite anzeigen',
						name: 'useNewsletter',
						checked: {if $useNewsletter}true{else}false{/if}
					}, {
						// Commentfield on confirm page
						xtype: 'checkbox',
						fieldLabel: 'Kommentarfeld auf der Bestellbest&auml;tigungsseite anzeigen',
						name: 'useComment',
						checked: {if $useComment}true{else}false{/if}
					}],
					buttons: [{
			        	text: 'Allgemeine Anpassungen speichern',
			        	name: 'saveGenerell',
			        	scope: this,
			        	handler: function() {
			        		this.generellPnl.getForm().submit({
			        			url: '{url controller="MobileTemplate" action="processGenerellForm"}',
			        			waitMsg: 'Sende Daten...',
			        			success: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Speichern erfolgreich',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.INFO
			        				});
			        			},
			        			failure: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Es ist ein Fehler aufgetreten',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.ERROR
			        				});
			        			}
			        		})
			        	}
			        }]
				}, {
					xtype: 'fieldset',
					title: 'Subshop-Anpassungen',
					labelWidth: 250,
					items: [{
						// Use Shopware Mobile as a subshop
						xtype: 'checkbox',
						fieldLabel: 'Shopware Mobile als Subshop verwenden',
						name: 'useAsSubshop',
						checked: {if $useAsSubshop}true{else}false{/if}
					}, {
						fieldLabel: 'Subshop-Auswahl',
			            xtype: 'combo',
			            mode: 'remote',
			            triggerAction: 'all',
			            name: 'subshopID',
			            value: '{$subshopID}',
			            store: this.subShopStore,
			            hiddenName: 'hiddenSubShopID',
			            displayField: 'displayText',
			            valueField: 'valueField'
					}],
					buttons: [{
			        	text: 'Subshop Anpassungen speichern',
			        	scope: this,
			        	handler: function() {
			        		this.generellPnl.getForm().submit({
			        			url: '{url controller="MobileTemplate" action="processGenerellForm"}',
			        			waitMsg: 'Sende Daten...',
			        			success: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Speichern erfolgreich',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.INFO
			        				});
			        			},
			        			failure: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Es ist ein Fehler aufgetreten',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.ERROR
			        				});
			        			}
			        		})
			        	}
			        }]
				}]
			});
			
			
			this.colorTemplateStore = new Ext.data.JsonStore({
				autoLoad: true,
				url: '{url controller="MobileTemplate" action="getColorTemplateStore"}',
				storeId: 'colorTemplateStore',
				root: 'data',
				idProperty: 'id',
				successProperty: 'success',
				totalProperty: 'totalCount',
				fields: [ 'id', 'value', 'displayText', 'previewImage' ],
				valueField: 'value',
				displayField: 'displayText'
			});
			
			this.statusbarStyleStore = new Ext.data.JsonStore({
				autoLoad: true,
				url: '{url controller="MobileTemplate" action="getStatusbarStyleStore"}',
				storeId: 'statusbarStyleStore',
				root: 'data',
				idProperty: 'id',
				successProperty: 'success',
				totalProperty: 'totalCount',
				fields: [ 'id', 'value', 'displayText' ],
				valueField: 'value',
				displayField: 'displayText'
			});

			/** Design related settings form panel */
			this.designFormPnl = new Ext.FormPanel({
				bodyBorder: false,
				id: 'designForm',
				labelWidth: 250,
				width: '70%',
				fileUpload: true,
				items: [{
					xtype: 'fieldset',
					title: 'Design-Anpassungen',
					items: [{
					
						// Checkboxes green
						xtype: 'checkbox',
						fieldLabel: 'AGB Hacken gr�n',
						name: 'checkboxesGreen',
						checked: {if $checkboxesGreen}true{else}false{/if}
					}, {

						// Sencha.io "Src"
						xtype: 'checkbox',
						fieldLabel: 'Sencha.io "Src" verwenden',
						name: 'useSenchaIO',
						checked: {if $useSenchaIO}true{else}false{/if}
					}, {

						// Show banners on start page
						xtype: 'checkbox',
						fieldLabel: 'Banner auf der Startseite anzeigen',
						name: 'showBanner',
						checked: {if $showBanner}true{else}false{/if}
					}, {
						// Colortemplate
			            fieldLabel: 'Farbtemplate',
			            xtype: 'combo',
			            mode: 'local',
			            triggerAction: 'all',
			            name: 'colorTemplate',
			            value: '{$colorTemplate}',
			            store: this.colorTemplateStore,
			            hiddenName: 'hiddenColorTemplate',
			            listeners: {
			            	scope: this,
			            	
			            	/** Change preview image on select */
			            	select: function(combo, rec, idx) {
			          		
			            		var previewImgPnl = Ext.getCmp('iphonePreview');
			            		var html = '<img src="'+ rec.data.previewImage +'" alt="Farbtemplate '+ rec.data.displayText +'" title="Farbtemplate '+ rec.data.displayText +'" />'
			            		
			            		previewImgPnl.body.update(html);
			            		previewImgPnl.doLayout();
			            		
			            	}
			            },
			            valueField: 'value',
   						displayField: 'displayText',
   						width: 300
			        }, {
			        	// Shoplogo - Uploadfield
			        	xtype: 'fileuploadfield',
			        	emptyText: '',
			        	fieldLabel: 'Shoplogo-Upload',
			        	buttonText: 'Logo ausw�hlen',
			        	name: 'logoUpload',
			        	width: 390,
			        	id: 'logoUpload',
			        	value: '{$logoUpload}'
			        }, {
			        	// Additional CSS settings
			        	xtype: 'textarea',
			        	fieldLabel: 'Zus�tzliche CSS-Eigenschaften',
			        	width: 300,
			        	height: 150,
			        	name: 'additionalCSS',
			        	value: '{$additionalCSS}'
			        }],
			        buttons: [{
			        	text: 'Design-Anpassungen speichern',
			        	scope: this,
			        	handler: function() {
			        		this.designFormPnl.getForm().submit({
			        			url: '{url controller="MobileTemplate" action="processDesignForm"}',
			        			waitMsg: 'Sende Daten...',
			        			success: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Speichern erfolgreich',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.INFO
			        				});
			        			},
			        			failure: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Es ist ein Fehler aufgetreten',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.ERROR
			        				});
			        			}
			        		})
			        	}
			        }]
				}, {
					xtype: 'fieldset',
					labelWidth: 250,
					title: 'iOS spezifische Anpassungen',
					items: [{
						// Notice for iOS devices only
						bodyBorder: false,
						html: '<p class="desc"><strong>Hinweis:</strong> Die hier gesetzten Einstellungen gelten nur f�r iOS-Ger�te wie dem iPhone, iPod touch und den iPad.</p>'
					}, {
						// Icon Upload
						xtype: 'fileuploadfield',
						emptyText: '',
						fieldLabel: 'Homescreen-Icon Upload',
						buttonText: 'Icon ausw�hlen',
						name: 'iconUpload',
						width: 390,
						id: 'iconUpload',
						value: '{$iconUpload}'
					}, {
						// Startup screen upload
						xtype: 'fileuploadfield',
						emptyText: '',
						fieldLabel: 'iOS Startupscreen Upload',
						buttonText: 'Screen ausw�hlen',
						name: 'startupUpload',
						width: 405,
						id: 'startupUpload',
						value: '{$startupUpload}'
					}, {
			        	// Statusbar style
			        	xtype: 'combo',
			        	mode: 'local',
			        	triggerAction: 'all',
			        	fieldLabel: 'Statusbar-Style',
			        	hiddenName: 'hiddenStatusbarStyle',
			        	hiddenValue: 'value',
			        	store: this.statusbarStyleStore,
			        	valueField: 'value',
						displayField: 'displayText',
   						name: 'statusbarStyle',
   						value: '{$statusbarStyle}',
   						width: 303
			        }, {
			        	// Gloss over icon
			        	xtype: 'checkbox',
			        	fieldLabel: 'Glanz �ber Icon anzeigen',
			        	name: 'glossOnIcon',
			        	checked: {if $glossOnIcon}true{else}false{/if}
			        }],
					buttons: [{
			        	text: 'iOS-Anpassungen speichern',
			        	scope: this,
			        	handler: function() {
			        		this.designFormPnl.getForm().submit({
			        			url: '{url controller="MobileTemplate" action="processDesignForm"}',
			        			waitMsg: 'Sende Daten...',
			        			success: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Speichern erfolgreich',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.INFO
			        				});
			        			},
			        			failure: function(form, response) {
			        				Ext.Msg.show({
			        					title: 'Es ist ein Fehler aufgetreten',
			        					msg: response.result.message,
			        					buttons: Ext.Msg.OK,
			        					icon: Ext.MessageBox.ERROR
			        				});
			        			}
			        		})
			        	}
			        }]
				}]
			});
			
			this.designPreviewPnl = new Ext.TabPanel({
				activeTab: 0,
				bodyBorder: false,
				title: 'Vorschau',
				padding: 10
			});
			
			this.iphonePreview = new Ext.Panel({
				title: 'Farbtemplate',
				id: 'iphonePreview',
				height: 372,
				bodyBorder: false,
				html: '<img src="{$pluginBase|cat:$colorTemplate}.jpg" />'
			});
			this.designPreviewPnl.add(this.iphonePreview);
			
			{if $logoUpload}
				this.logoPreview = new Ext.Panel({
					title: 'Logo',
					id: 'logoPreview',
					bodyBorder: false,
					html: '<img src="{$logoUpload}" />'
				});
				this.designPreviewPnl.add(this.logoPreview);
			{/if}
			
			{if $iconUpload}
				this.iconPreview = new Ext.Panel({
					title: 'Icon',
					id: 'iconPreview',
					bodyBorder: false,
					html: '<img src="{$iconUpload}" />'
				});
				this.designPreviewPnl.add(this.iconPreview);
			{/if}
			
			{if $startupUpload}
				this.startupPreview = new Ext.Panel({
					title: 'Startup',
					id: 'startupPreview',
					bodyBorder: false,
					html: '<img src="{$startupUpload}" />'
				});
				this.designPreviewPnl.add(this.startupPreview);
			{/if}
			
			/** Container panel for the both design panels */
			this.designPnl = new Ext.Panel({
				layout: 'hbox',
				padding: 15,
				autoScroll: true,
				bodyBorder: false,
				title: 'Design-Anpassungen',
				items: [this.designFormPnl, this.designPreviewPnl]
			});
			
			this.nativeFieldSet = new Ext.form.FieldSet({
				title: 'Native Applikation einreichen',
				labelWidth: 250,
				defaults: {
					width: 400
				},
				items: [{
					xtype: 'textfield',
					name: 'contactPerson',
					fieldLabel: 'Ansprechpartner',
					emptyText: 'Max Mustermann',
					required: true,
					allowBlank: false
				}, {
					xtype: 'textarea',
					name: 'msg',
					fieldLabel: 'Anfrage-Text',
					emptyText: 'Ihre Anfrage folgt hier',

					required: true,
					allowBlank: false,
					height: 225
				}]
			});
			
			this.holderPnl = new Ext.Panel({
				layout: 'hbox',
				bodyBorder: false,
				items: [this.nativeFieldSet]
			});
			
			/** Native application panel */
			this.nativePnl = new Ext.FormPanel({				
				padding: 15,
				autoScroll: true,
				fileUpload: true,
				disabled: false,
				title: 'Native Applikation einreichen',
				items: [{
					// Price information
					bodyBorder: false,
					cls: 'native_teaser',
					html: '<h2>Shopware Mobile - Native Applikation</h2><p>Shopware Mobile kann auch als native App bereitgestellt werden. So k�nnen Sie als Shopbetreiber die App Stores von Apple, Android und co. als zus�tzliches Marketinginstrument nutzen und sich dauerhaft auf den Smartphones Ihrer Kunden platzieren.</p><p>F�llen Sie hierzu das Formular "Native Applikation einreichen" aus. Nach der erfolgreichen &Uuml;bermittelung Ihrer Daten werden wir mit Ihnen in Kontakt treten um weitere Einzelheiten zu kl&auml;ren.</p><p class="price"><strong>Einmalige Einrichtungsgeb&uuml;hr:</strong> <span>99,00 &euro;</span></p><p class="price"><strong>Monatliche Kosten:</strong> <span>79,00 &euro;</span></p>'

				}, this.holderPnl],
				buttons: [{
					text: 'Applikationseinstellungen speichern',
					scope: this,
		        	handler: function() {
		        		this.nativePnl.getForm().submit({
		        			url: '{url controller="MobileTemplate" action="processNativeApplicationForm"}',
		        			waitMsg: 'Sende Daten...',
		        			success: function(form, response) {
		        				Ext.Msg.show({
		        					title: 'Speichern erfolgreich',
		        					msg: response.result.message,
		        					buttons: Ext.Msg.OK,
		        					icon: Ext.MessageBox.INFO
		        				});
								form.reset();
		        			},
		        			failure: function(form, response) {
		        				Ext.Msg.show({
		        					title: 'Es ist ein Fehler aufgetreten',
		        					msg: response.result.message,
		        					buttons: Ext.Msg.OK,
		        					icon: Ext.MessageBox.ERROR
		        				});
		        			}
		        		})
		        	}
				}]
			});


			/** Main tabpanel navigation */
			this.tabPnl = new Ext.TabPanel({
				activeTab: 0,
				region: 'center',
				autoWidth: false,
				items: [this.generellPnl, this.designPnl, this.nativePnl]
			});
			
			this.items = [this.tabPnl];
			
	    	View.superclass.initComponent.call(this);
	    }
	});
	Shopware.SwagMobileTemplate.View = View;
})();
Ext.onReady(function(){
	OurView = new Shopware.SwagMobileTemplate.View;
});
</script>
{/block}