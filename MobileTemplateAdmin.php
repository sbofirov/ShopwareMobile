<?php
/**
 * [plugin]
 * @link http://www.shopware.de
 * @package Plugins
 * @subpackage [scope]
 * @copyright Copyright (c) [year], shopware AG
 * @version [version] [date] [revision]
 * @author [author]
 */
class Shopware_Controllers_Backend_MobileTemplate extends Enlight_Controller_Action
{
	/** {obj} Shopware configuration object */
	protected $config;
	
	/** {arr} Plugin configuration */
	protected $props;
	
	/** {obj} Shopware database object */
	protected $db;
	
	/** {str} Upload path for the logo, icon and startup screen */
	protected $uploadPath;
	
	/** {int} Max. upload size of a file */
	protected $maxFileSize;
	
	/** {arr} Allowed file extension */
	protected $fileExtensions;
	
	/** {str} HTTP base path */
	protected $basePath;
	
	/** {str} HTTP plugin views path */
	protected $pluginPath;
	
	/** {arr} Color templates */
	protected $colorTemplates;
	
	/**
	 * init()
	 *
	 * Initializiert die benoetigten Views und setzt globale Variablen
	 *
	 * @access public
	 * @return void
	 */
	public function init()
	{
		$this->config = Shopware()->Config();
		$this->uploadPath = Shopware()->DocPath() . '/images/swag_mobiletemplate';
		$this->db = Shopware()->Db();
		
		// Get max file upload size from the php.ini 
		$iniMaxSize = ini_get('post_max_size');
		$unit = strtoupper(substr($iniMaxSize, -1));
		$multiplier = ($unit == 'M' ? 1048576 : ($unit == 'K' ? 1024 : ($unit == 'G' ? 1073741824 : 1)));
		$maxFileSizeValue = substr($iniMaxSize, 0, -1);
		
		// Upload size in bytes
		$this->maxFileSize = $maxFileSizeValue * $multiplier;
		
		// Set allowed file extensions
		$this->fileExtensions = array("jpg", "jpeg", "tif", "tiff", "gif", 'png');
		
		// Get all settings
		$props = $this->db->query('SELECT * FROM `s_plugin_mobile_settings`');
		$props = $props->fetchAll();
		
		$properties = array();
		foreach($props as $prop) {
			$properties[$prop['name']] = $prop['value'];
		}
		
		$this->props = $properties;
		
		// Set plugin base path
		$docPath = Enlight::Instance()->DocPath();
		$request = Enlight::Instance()->Front()->Request();
		$this->basePath = $request->getScheme().'://'. $request->getHttpHost() . $request->getBasePath() . '/';
		
		$path = explode($docPath, dirname(__FILE__));
		$path = $path[1];
		$this->pluginPath = $this->basePath . $path . '/Views/backend/mobile_template/img/colortemplates/';
		
		// Set colorTemplates array
		$this->colorTemplates = array(
			'data' => array(
				array('value' => 'android', 'displayText' => 'Android-Style'),
				array('value' => 'blue', 'displayText' => 'Blau'),
				array('value' => 'default', 'displayText' => 'Standard'),
				array('value' => 'green', 'displayText' => utf8_encode('Gr�n')),
				array('value' => 'ios', 'displayText' => 'iOS-Style'),
				array('value' => 'orange', 'displayText' => 'Orange'),
				array('value' => 'pink', 'displayText' => 'Pink'),
				array('value' => 'red', 'displayText' => 'Rot'),
				array('value' => 'turquoise', 'displayText' => utf8_encode('T�rkis'))
			)
		);

		$this->View()->addTemplateDir(dirname(__FILE__) . "/Views/");
	}
 	
 	/**
 	 * indexAction()
 	 *
 	 * Liest alle Plugin-Einstellungen aus und stellt diese der View
 	 * zur Verfuegung
 	 *
 	 * @access public
 	 * @return void
 	 */
	public function indexAction()
	{
		// Assign plugin props to view
		foreach($this->props as $k => $v) {
			$this->View()->assign($k, $v);
		}
		
		$this->View()->assign('pluginBase', $this->pluginPath);
		
		// Supported devices
		$data = array(
			array('boxLabel' => 'iPhone', 'name' => 'iphone'),
			array('boxLabel' => 'iPod', 'name' => 'ipod'),
			array('boxLabel' => 'iPad (experimental)', 'name' => 'ipad'),
			array('boxLabel' => 'Android', 'name' => 'android'),
			array('boxLabel' => 'BlackBerry (experimental)', 'name' => 'blackberry')
		);
		$properties = strtolower($this->props['supportedDevices']);
		$properties = explode('|', $properties);
		
		// Set checked attribute
		foreach($data as $k => $v) {
			if(in_array($v['name'], $properties)) {
				$data[$k]['checked'] = true;
			}
		}
		$this->View()->assign('supportedDevicesJSON', Zend_Json::encode($data));
		
		// Get paymentmeans
		$paymentmeans = $this->db->query("SELECT `id`, `name`, `description`, `additionaldescription` FROM `s_core_paymentmeans`");
		$paymentmeans = $paymentmeans->fetchAll();
		
		// Supported paymentmeans
		$supportedPaymentmeans = explode('|', $this->props['supportedPayments']);
		$availablePayments = array(3, 4, 5);
		$payments = array();
		foreach($paymentmeans as $k => $v) {
			if(in_array($v['id'], $availablePayments)) {
				if(in_array($v['id'], $supportedPaymentmeans)) {
					$payments[] = array(
						'boxLabel' => utf8_encode($v['description']),
						'checked' => true,
						'name' => utf8_encode($v['name'])
					);
				} else {
					$payments[] = array(
						'boxLabel' => utf8_encode($v['description']),
						'name' => utf8_encode($v['name'])
					);
				}
			} else {
				$payments[] = array(
					'boxLabel' => utf8_encode($v['description'] . ' (noch nicht unterst�tzt)'),
					'disabled' => true,
					'name' => utf8_encode($v['name'])
				);
			}
		}
		$this->View()->assign('supportedPaymentmeansJSON', Zend_Json::encode($payments));
	}
 	
 	/**
 	 * skeletonAction()
 	 *
 	 * Leere Funktion
 	 *
 	 * @access public
 	 * @return void
 	 */
	public function skeletonAction()
	{
	}
	
	/**
	 * processGenerellFormAction()
	 *
	 * Verarbeitet die allgemeinen Einstellungen des Plugins
	 *
	 * @access public
	 * @return void
	 */
	public function processGenerellFormAction()
	{
		$request = $this->Request();
		
		// Supported devices
		$supportedDevices = array();
		$iphone = $request->getParam('iphone');
		if(!empty($iphone)) {
			$supportedDevices[] = 'iPhone';
		}
		$ipod = $request->getParam('ipod');
		if(!empty($ipod)) {
			$supportedDevices[] = 'iPod';
		}
		$ipad = $request->getParam('ipad');
		if(!empty($ipad)) {
			$supportedDevices[] = 'iPad';
		}
		$android = $request->getParam('android');
		if(!empty($android)) {
			$supportedDevices[] = 'Android';
		}
		$blackBerry = $request->getParam('blackberry');
		if(!empty($blackBerry)) {
			$supportedDevices[] = 'BlackBerry';
		}
		$supportedDevices = implode('|', $supportedDevices);
		$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$supportedDevices' WHERE `name` LIKE 'supportedDevices';");
		
		// Supported paymentmeans
		$supportedPaymentmeans =  array();
		$cash = $request->getParam('cash');
		if(!empty($cash)) {
			$supportedPaymentmeans[] = 3;
		}
		$invoice = $request->getParam('invoice');
		if(!empty($invoice)) {
			$supportedPaymentmeans[] = 4;
		}
		$prepayment = $request->getParam('prepayment');
		if(!empty($prepayment)) {
			$supportedPaymentmeans[] = 5;
		}
		$supportedPaymentmeans = implode('|', $supportedPaymentmeans);
		$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$supportedPaymentmeans' WHERE `name` LIKE 'supportedPayments';");
		
		//Shopsite-ID AGB
		$agbInfoID = $request->getParam('agbInfoID');
		if(isset($agbInfoID)) {
			$agbInfoID = (int) $agbInfoID;
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$agbInfoID' WHERE `name` LIKE 'agbInfoID';");
		}
		
		//Shopsite-ID Right of Revocation
		$cancelRightID = $request->getParam('cancelRightID');
		if(isset($cancelRightID)) {
			$cancelRightID = (int) $cancelRightID;
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$cancelRightID' WHERE `name` LIKE 'cancelRightID';");
		}
		
		//Infosite group name
		$infoGroupName = $request->getParam('infoGroupName');
		if(isset($infoGroupName)) {
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$infoGroupName' WHERE `name` LIKE 'infoGroupName';");
		}
		
		// Show normal version link
		$showNormalVersionLink = $request->getParam('showNormalVersionLink');
		if(isset($showNormalVersionLink)) {
			if($showNormalVersionLink == 'on') {
				$showNormalVersionLink = 1;
			} else {
				$showNormalVersionLink = 0;
			}
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$showNormalVersionLink' WHERE `name` LIKE 'showNormalVersionLink';");
		}
		
		$message = 'Das Formular wurde erfolgreich gespeichert.';
		echo Zend_Json::encode(array('success' => true, 'message' => $message));
		die();
	}
	
	/**
	 * processSubshopFormAction()
	 *
	 * Verarbeitet die Subshop Einstellungen des Plugins
	 *
	 * @access public
	 * @return void
	 */
	public function processSubshopFormAction()
	{
		$request = $this->Request();
		
		// Use Shopware Mobile as Subshop
		$useAsSubshop = $request->getParam('useAsSubshop');
		if(isset($useAsSubshop)) {
			if($useAsSubshop == 'on') {
				$useAsSubshop = 1;
			} else {
				$useAsSubshop = 0;
			}
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$useAsSubshop' WHERE `name` LIKE 'useAsSubshop';");
		}
		
		//Subshop-ID
		$subshopID = $request->getParam('hiddenSubshop');
		if(isset($subshopID)) {
			$subshopID = intval($subshopID);
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$subshopID' WHERE `name` LIKE 'subshopID';");
		}
		
		$message = 'Das Formular wurde erfolgreich gespeichert.';
		echo Zend_Json::encode(array('success' => true, 'message' => $message));
		die();
	}
	
	/**
	 * processDesignFormAction()
	 *
	 * Verarbeitet die allgemeinen Einstellungen des Plugins
	 *
	 * @access public
	 * @return void
	 */
	public function processDesignFormAction()
	{
		$logoUpload    = $_FILES['logoUpload'];
		$startupUpload = $_FILES['startupUpload'];
		$iconUpload    = $_FILES['iconUpload'];
		$request       = $this->Request();
		
		// Check if the user chooses a new logo
		if(is_array($logoUpload) && !empty($logoUpload) && $logoUpload['size'] > 0) {
			$logo = $this->processUpload($logoUpload, 'logo', 'logo');
			$logoImage = $logo['image'];
			$logoHeight = $logo['height'];
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$logoImage' WHERE `name` LIKE 'logoUpload';");
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$logoHeight' WHERE `name` LIKE 'logoHeight';");
		}
		
		// Check if the user chooses a new icon
		if(is_array($iconUpload) && !empty($iconUpload) && $iconUpload['size'] > 0) {
			$icon = $this->processUpload($iconUpload, 'icon', 'icon');
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$icon' WHERE `name` LIKE 'iconUpload';");
		}
		
		// Check if the user chooses a new startup screen
		if(is_array($startupUpload) && !empty($startupUpload) && $startupUpload['size'] > 0) {
			$startup = $this->processUpload($startupUpload, 'startup', 'startup');
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$startup' WHERE `name` LIKE 'startupUpload';");
		}
		
		// Sencha.IO
		$useSenchaIO = $request->getParam('useSenchaIO');
		if(isset($useSenchaIO)) {
			if($useSenchaIO == 'on') {
				$useSenchaIO = 1;
			} else {
				$useSenchaIO = 0;
			}
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$useSenchaIO' WHERE `name` LIKE 'useSenchaIO';");
		}
		
		// Voucher on confirm page
		$useVoucher = $request->getParam('useVoucher');
		if(isset($useVoucher)) {
			if($useVoucher == 'on') {
				$useVoucher = 1;
			} else {
				$useVoucher = 0;
			}
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$useVoucher' WHERE `name` LIKE 'useVoucher';");
		}
		
		// Newsletter signup on confirm page
		$useNewsletter = $request->getParam('useNewsletter');
		if(isset($useNewsletter)) {
			if($useNewsletter == 'on') {
				$useNewsletter = 1;
			} else {
				$useNewsletter = 0;
			}
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$useNewsletter' WHERE `name` LIKE 'useNewsletter';");
		}
		
		// Commentfield on confirm page
		$useComment = $request->getParam('useComment');
		if(isset($useComment)) {
			if($useComment == 'on') {
				$useComment = 1;
			} else {
				$useComment = 0;
			}
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$useComment' WHERE `name` LIKE 'useComment';");
		}
		
		// Colortemplate
		$colorTemplate = $request->getParam('hiddenColorTemplate');
		if(isset($colorTemplate)) {
			
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$colorTemplate' WHERE `name` LIKE 'colorTemplate';");
		}
		
		// Additional CSS
		$additionalCSS = $request->getParam('additionalCSS');
		if(isset($additionalCSS)) {
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$additionalCSS' WHERE `name` LIKE 'additionalCSS';");
		}
		
		// Statusbar style
		$statusbarStyle = $request->getParam('hiddenStatusbarStyle');
		if(isset($statusbarStyle)) {
		
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$statusbarStyle' WHERE `name` LIKE 'statusbarStyle';");
		}
		
		// Gloss on icon
		$glossOnIcon = $request->getParam('glossOnIcon');
		if(isset($glossOnIcon)) {
			if($glossOnIcon == 'on') {
				$glossOnIcon = 1;
			} else {
				$glossOnIcon = 0;
			}
			$this->db->query("UPDATE `s_plugin_mobile_settings` SET `value` = '$glossOnIcon' WHERE `name` LIKE 'glossOnIcon';");
		}
		
		$message = 'Das Formular wurde erfolgreich gespeichert.';
		echo Zend_Json::encode(array('success' => true, 'message' => $message));
		die();
	}

	/**
	 * getColorTemplateStoreAction()
	 *
	 * Gibt alle verfuegbaren Farbtemplates als JSON String aus
	 *
	 * @return void
	 */
	public function getColorTemplateStoreAction()
	{		
		$extension = '.jpg';
		
		// Basic data array
		$data = $this->colorTemplates;
				
		$selected = $this->props['colorTemplate'];
		foreach($data['data'] as $k => $v) {
			// Set id
			$data['data'][$k]['id'] = $k;
			
			// Set selected attribute
			if($v['value'] == $selected) {
				$data['data'][$k]['selected'] = true;
			}
			
			// Set preview image
			$data['data'][$k]['previewImage'] = $this->pluginPath . $v['value'] . $extension; 
		}
		
		// Set totalCount
		$data['totalCount'] = count($data['data']);
		
		// Set success attribute
		$data['success'] = true;
		
		echo Zend_Json::encode($data);
		die();
	}

	/**
	 * getSubshopStoreAction()
	 *
	 * Gibt alle verfuegbaren Subshops als JSON String aus
	 *
	 * @return void
	 */
	public function getSubshopStoreAction()
	{
		$sql = "SELECT id, id AS valueField, name AS displayText FROM `s_core_multilanguage` GROUP BY id";
		$result = $this->db->fetchAll($sql);

		$selected = $this->props['subshopID'];
		foreach($result as $k => $v) {
			if($v['id'] == $selected) {
				$result[$k]['selected'] = true;
			}
		}

		$data['data'] = $result;
		$data['totalCount'] = count($result);
		$data['success'] = true;

		echo Zend_Json::encode($data);
		die();
	}

	/**
	 * getStatusbarStyleStoreAction()
	 *
	 * Gibt alle verfuegbaren Statusbar-Styles als JSON String aus
	 *
	 * @return void
	 */
	public function getStatusbarStyleStoreAction()
	{
		$data = array(
			'data' => array(
				array('value' => 'default', 'displayText' => 'Standard'),
				array('value' => 'black', 'displayText' => 'Schwarz'),
				array('value' => 'black-translucent', 'displayText' => 'Schwarz-transparent')
			)
		);
		
		$selected = $this->props['statusbarStyle'];
		foreach($data['data'] as $k => $v) {
		
			// Set id
			$data['data'][$k]['id'] = $k;
			
			// Set selected attribute
			if($v['value'] == $selected) {
				$data['data'][$k]['selected'] = true;
			}
		}
		
		// Set totalCount
		$data['totalCount'] = count($data['data']);
		
		// Set success attribute
		$data['success'] = true;
		
		echo Zend_Json::encode($data);
		die();
	}
	
	/**
	 * processNativeApplicationFormAction()
	 *
	 * Verarbeitet die "Native Applikation"-Form
	 *
	 * @access public
	 */
	public function processNativeApplicationFormAction()
	{
		$request = $this->Request();
		
		$title = $request->getParam('title');
		$appID = $request->getParam('appid');
		$version = $request->getParam('version');
		$desc = $request->getParam('desc');
		
		$data = array(
			'title'   => $title,
			'package' => $appID,
			'version' => $version,
			'desc'    => $desc
		);
		
		// Grab the source code of the mobile template
		$path = $this->scrapePageSourceCode($this->uploadPath . '/index.html');
		
		// Add application to our PhoneGap Dashboard
		$this->addNativeApplication($path, $data);
		
		// Return Message
		$message = 'Das Formular wurde erfolgreich gespeichert. Wir werden in K&uuml;rze mit Ihnen in Kontakt treten.';
		echo Zend_Json::encode(array('success' => true, 'message' => $message));
		die();
	}
	
	////////////////////////////////////////////
    //Helper Functions
    ////////////////////////////////////////////
    
    /**
     * addNativeApplication()
     *
     * Fuegt eine neue Applikation zum "build.phonegap.com"-Dashboard hinzu
     * und verschickt eine E-Mail an eine definierte Adresse, damit die Applikation
     * abgerechnet und in den AppStore gestellt werden kann.
     *
     * @access private
     * @param str $filePath
     * @param arr $dataRaw
	 * @return bool
     */
    private function addNativeApplication($filePath, $dataRaw)
    {
    	$data = json_encode($dataRaw);
    	
    	$file = $this->uploadPath . '/index.html';    	
    	$param = array(
    		'data' => $data,
    		'file' => "@$file"
    	);

		//... add build.phonegap request
		
		return true;
    }
	
	/**
	 * scrapePageSourceCode()
	 *
	 * Laedt den Quelltext des Mobile Templates herunter und schreibt diesen in den angegeben Pfad
	 *
	 * @access private
	 * @param str $path
	 * @return str $path
	 */
	private function scrapePageSourceCode($path)
	{
		$iPhoneUserAgent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko)";
		
		// Support subshops
		if($this->props['useAsSubshop']) {
			$params = array(
				'sLanguage' => $this->props['subshopID'],
				'sMobile'   => 1
			);
		} else {
			$params = array(
				'sMobile' => 1
			);
		}
		
		// Fetch data
		$data =  $this->getData($this->basePath, $params, $iPhoneUserAgent);
		
		// Save data
		if(file_put_contents($path, $data) == false) {
			return false;
		}
		
		return $path;
	}
	
	
	/**
	 * getData()
	 *
	 * Fragt Daten per cURL ab und gibt diese als String zurueck
	 *
	 * @access private 
	 * @param str $url - URL, die abgefragt werden soll
	 * @param str $post - POST Variablen, die mitgesendet werden sollen
	 * @param str $userAgent - User Agent mit dem der Request gesendet werden soll
	 * @param str $login - Login Informationen (username, password)
	 * @param int $timeout - Timeout in Minuten
	 * @return str $data
	 */
	private function getData($url, $post = '', $userAgent = '', $login = '', $timeout = 5)
	{
		// Initialize cURL 
		$ch = curl_init();
		
		// Set POST variables
		if(!empty($post) && is_array($post)) {
			//curl_setopt($ch, CURLOPT_POST, $postCount);
			curl_setopt($agent, CURLOPT_POST, true);
			curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
		}
		
		// Set User agent
		if(!empty($userAgent)) {
			curl_setopt($ch, CURLOPT_USERAGENT, $userAgent);
		}
		
		// Set login informations
		if(!empty($login)) {
			curl_setopt($ch, CURLOPT_USERPWD, $login['username'] . ':' . $login['password']); 
		}
		
		// Set url
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch,CURLOPT_CONNECTTIMEOUT,$timeout);
		
		// Execute request
		$data = curl_exec($ch);
		curl_close($ch);
		return $data;
	}
    
    /**
     * processUpload()
     *
     * Laedt die angegeben Datei hoch und validiert diese
     *
     * @access private
     * @param arr $upload - $_FILES array
     * @param str $filename - Der zuverwendene Dateiname
     * @param str $imageType - Typ des Bildes (Logo, Icon, Startup-Screen)
     * @return str $path - Pfad zum Bild
     */
    private function processUpload($upload, $filename, $imageType)
    {
    	// Check upload path
    	if(!is_dir($this->uploadPath)) {
			if(!mkdir($this->uploadPath, 0777)) {
				$message = 'Das Uploadverzeichnis "' . $this->uploadPath . '" ben&ouml;tigt die Rechte 0777.';
				echo Zend_Json::encode(array('success' => false, 'message' => $message));
				die();
			}
		}
		
		// Validate file size
		$file_size = @filesize($upload["tmp_name"]);
		if (!$file_size || $file_size > $this->maxFileSize) {
			$message = 'Die von Ihnen gew&auml;hlte Datei &uuml;bersteigt das Uploadlimit.';
			echo Zend_Json::encode(array('success' => false, 'message' => $message));
			die();
		}
		if ($file_size <= 0) {
			$message = 'Die von Ihnen gew&auml;hlte Datei konnte nicht hochgeladen werden.';
			echo Zend_Json::encode(array('success' => false, 'message' => $message));
			die();
		}
		
		// Validate file extension
		$path_info = pathinfo($upload['name']);
		$file_extension = $path_info["extension"];
		$is_valid_extension = false;
		foreach ($this->fileExtensions as $extension) {
			if (strcasecmp($file_extension, $extension) == 0) {
				$is_valid_extension = true;
				$file_extension = $extension;
				break;
			}
		}
		if (!$is_valid_extension) {
			$message = 'Die Datei besitzt einen Dateitypen der nicht unterst&uuml;tzt wird';
			echo Zend_Json::encode(array('success' => false, 'message' => $message));
			die();
		}
		
		// Check image size
		list($width, $height, $type, $attr) = getimagesize($upload['tmp_name']);
		if($width <= 0) {
			$message = 'Das Bild hat eine Breite von weniger als 0 Pixel.';
			echo Zend_Json::encode(array('success' => false, 'message' => $message));
			die();
		}
		
		// Image type related size checking
		switch($imageType) {
			case 'icon':
				if($width != 72 || $height != 72) {
					$message = 'Das Icon muss eine Gr&ouml;&szlig;e von 72 Pixel x 72 Pixel aufweisen. Bitte w&auml;hlen Sie ein anderes Bild als Icon.';
					echo Zend_Json::encode(array('success' => false, 'message' => $message));
					die();
				}
				break;
			case 'startup':
				if($width > 640 || $height > 960) {
					$message = 'Der Startup-Screen muss eine maximale Gr&ouml;&szlig;e von 640 Pixel x 960 Pixel aufweisen. Bitte w&auml;hlen Sie ein anderes Bild als Startup-Screen.';
					echo Zend_Json::encode(array('success' => false, 'message' => $message));
					die();
				}
				break;
			case 'logo':
			default:
				if($width > 320) {
					$message = 'Das Logo darf maximal eine Gr&ouml;&szlig;e von maximal 320 Pixeln aufweisen. Bitte w&auml;hlen Sie ein anderes Bild als Logo.';
					echo Zend_Json::encode(array('success' => false, 'message' => $message));
					die();
				}
				break;
		}
		
		// Set generic file name
		$upload['name'] = $filename . '.' . $file_extension;
		
		$path = $this->uploadPath . '/' . $upload['name'];
		
		// Process the file
		if (!@move_uploaded_file($upload["tmp_name"], $path)) {
			$message = 'Die Datei konnte nicht gespeichert werden.';
			echo Zend_Json::encode(array('success' => false, 'message' => $message));
			die();
		}

		if($imageType == 'logo') {
			return array('image' => $this->basePath . 'images/swag_mobiletemplate/' . $upload['name'], 'height' => $height);
		} else {
			return $this->basePath . 'images/swag_mobiletemplate/' . $upload['name'];
		}
    }
}