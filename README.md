# Shopware Mobile Beta 2

- **Required shopware version**: >= 3.5.4
- **Current stable tag**: 1.2.4
- **Used framework**: Sencha Touch v1.1.0

### Supported devices:

* iOS starting from Version 3.1.2 (iOS 4/iPhone 4 recommend)
* Android starting from Version 2.2 "Froyo"
* BlackBerry OS starting from Version 6

### Feature list:

* Usable as a subshop
* Customer login and registration
* Support for bundles, articles, configurator and liveshopping articles
* full-fledged search based on the normal search component
* Post comments right from your smartphone
* Support for banners in subcategories
* Promotions carrousel on the start page
* Tracking orders and registrations via a subshop configuration
* Dynamic calulation of the basket summary

# Installation from the github.com repository

1. Create a new folder to place clone in the repository using `$ mkdir Frontend` and change it that folder using `$ cd Frontend`
2. Clone the repository from github.com using `$ git clone git://github.com/ShopwareAG/ShopwareMobile.git`
3. Rename the cloned repository to *SwagMobileTemplate* using `$ mv ShopwareMobile SwagMobileTemplate`
4. Now go to the parent folder using `$ cd ..` and create a ZIP-Archive of the plugin using `zip -r SwagMobileTemplate.zip Frontend`
5. Clean up the mess and delete the *Frontend* folder using `$ rm -rf Frontend`

Now head over to your Shopware Backend (e.g. `http://example.de/shop/backend`), login and open up the plugin manager. To install the plugin change the tab to "Plugin hinzuf&uuml;gen" and upload the generated ZIP-archive using the "Plugin per Datei-Upload hinzuf&uuml;gen"

---

Here's the complete workflow to create an easy to use install package from Shopware Mobile
    $ mkdir Frontend
    $ cd Frontend
    $ git clone git://github.com/ShopwareAG/ShopwareMobile.git
    $ mv ShopwareMobile SwagMobileTemplate
    $ cd .. && zip -r SwagMobileTemplate.zip Frontend
    $ rm -rf Frontend
    
# Hacking

Every developer is welcome to contribute the development of Shopware Mobile. Just start up your terminal, clone the repository using `$ git clone git://github.com/ShopwareAG/ShopwareMobile.git` and start developing.
If you're done, just send us a pull request. We'll verify the pull request and merge it with the master repository.

# Copying

Shopware Mobile is distributed under the terms of the GNU General Public License version 3. The complete license text could be found in the *LICENSE* file

# Changelog

The changelog is located under

`https://github.com/ShopwareAG/ShopwareMobile/commits/master`