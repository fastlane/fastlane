'use strict';

define(['app'], function (staticApp) {
	var loginController = function($scope, $rootScope, $location, $cookies, $stateParams, staticServices) {
		
        $scope.parentScopeLoaded = false;
        $scope.pageLoaded = false;
        $scope.showLearnMorePanel = true;
        $scope.normalLogin = true;
        $scope.appleMusicLogin = false;
        $scope.podcastLogin = false;
        $scope.errorKey = false;
        window.scope = $scope;

		$scope.$parent.$watch('parentScopeLoaded',function(val) {
            if (val) {
                $rootScope.currentPage = 'login';
                $scope.parentScopeLoaded = true;
                $scope.setupDSiFrame();
                $scope.setisReady();
            }
        });

        $scope.setisReady = function() {
            if ($scope.parentScopeLoaded && $scope.pageLoaded) {
            	$rootScope.isReady = true;
            } else {
                $rootScope.isReady = false;
            }
        }

        $scope.checkLoginType = function() {

            // 6 = artist
            if ($stateParams.view == '6' || $cookies.itcLoginCt == '6') {
                $scope.normalLogin = false;
                $scope.appleMusicLogin = true;
                $scope.podcastLogin = false;
                $rootScope.loginType = 'artist';
            }
            // 5 = podcast
            else if ($stateParams.view == '5' || $cookies.itcLoginCt == '5') {
                $scope.normalLogin = false;
                $scope.appleMusicLogin = false;
                $scope.podcastLogin = true;
                $rootScope.loginType = 'podcast';
            }
            // 1 = normal itc
            else if ($stateParams.view == '1') {
                $scope.normalLogin = true;
                $scope.appleMusicLogin = false;
                $scope.podcastLogin = false;
            }
            
            $rootScope.loginType = $rootScope.loginType;
        }

        $scope.checkForErrors = function() {
            if (!$stateParams.errorKey) return;
            $scope.errorKey = $stateParams.errorKey;
        }

        $scope.getCookies = function() {
            if ($cookies.itcLoginVisitedBefore == 'true') {
                $scope.showLearnMorePanel = false;  
                $rootScope.darkFooter = false;
            }
            else {
                $rootScope.darkFooter = true;
            }
        }

        $scope.setCookies = function() {
            $cookies.itcLoginVisitedBefore = 'true';
            if ($stateParams && $stateParams.view) $cookies.itcLoginCt = $stateParams.view;
        }

        var getEnv = function(host) {
            var seperator = '-';
            if (host.indexOf(seperator) < 0) return null;
            else return host.split(seperator)[0];
        }

        var getSubdomain = function(host) {
            var seperator = '.';
            if (host.indexOf(seperator) < 0) return null;
            else return host.split(seperator)[0];
        }

        $scope.setupDSiFrame = function() {
            var itcProdUrl = 'itunesconnect.apple.com';
            var itcServiceUrl = 'https://idmsa.apple.com/appleauth';
            var itcServiceUrlStable = 'https://idmsauth-stable.corp.apple.com/appleauth';
            var itcServiceUrlUat = 'https://idmsauth-uat.corp.apple.com/appleauth';
            var itcServiceKey = '22d448248055bab0dc197c6271d738c3'; // for itunesconnect.apple.com
            var itcServiceKeyDevItms8 = 'dd9cea41f269008e7f1403a24cfbafe2';
            var currentHost = $location.host();

            

            var itcAppUrl =  $location.protocol() + "://" + currentHost + $stateParams.path;
            if ($rootScope.loginType) itcAppUrl = itcAppUrl + '?ct=' + $rootScope.loginType;

            var environment = getEnv(currentHost);
            if (environment != null) {
                var envNum = environment.match(/\d+/); 
                if (envNum != null) {
                    envNum = envNum[0];
                    switch (envNum) {
                        case '5':
                            itcServiceUrl = itcServiceUrlUat;
                            itcServiceKey = 'e8d70ccc118e009722ffde066269dcfd';
                            break;
                        case '6':
                            itcServiceUrl = itcServiceUrlUat;
                            itcServiceKey = '70a6ee3acccc2f883bf9c45ea3ed71c3';
                            break;
                        case '7':
                            itcServiceUrl = itcServiceUrlUat;
                            itcServiceKey = '0c4530ccf7a70bbcd7b8f4734482b65a';
                            break;
                        case '8':
                            itcServiceUrl = itcServiceUrlStable;
                            itcServiceKey = itcServiceKeyDevItms8;
                            break;
                        case '9':
                            itcServiceUrl = itcServiceUrlUat;
                            itcServiceKey = '9249bf5e254fc633460e3cbfd8171daf';
                            break;
                    }
                }
                else if (environment == 'origin') itcServiceKey = '0bcc3499e16ee45d885d118869dbad57';
            }

            var loginHeaderText = $scope.l10n.interpolate('ITC.Login.iTunesConnect');
            if ($rootScope.loginType == 'artist') loginHeaderText = $scope.l10n.interpolate('ITC.Login.AppleMusic');
            else if ($rootScope.loginType == 'podcast') loginHeaderText = $scope.l10n.interpolate('ITC.Login.Podcast');

            var initOptions = {
                serviceKey: itcServiceKey,
                serviceURL: itcServiceUrl,
                containerId: 'idms-auth-container',
                signInLabel: loginHeaderText,
                theme: 'lite',
                features: {
                    rememberMe: true
                },
                callbacks: {
                    onAuthSuccess: function (result) {
                        window.location = itcAppUrl;
                    }, 
                    onAuthFailure: function (result) {
                        console.log('Auth failure.', result);
                    },
                    onPasswordAuthDone: function (isSuccess) {
                        if (!isSuccess) {
                            $scope.$apply(function(){
                                $scope.errorKey = null;
                            })
                        }
                    }
                }
            };

            if (!envNum && environment != 'origin' && currentHost != itcProdUrl) {
                initOptions.devAppDomain = $location.protocol() + "://" + currentHost;;
                initOptions.serviceKey = itcServiceKeyDevItms8;
                initOptions.serviceURL = itcServiceUrlStable;
            }

            window.AppleID.service.auth.init(initOptions);
        }

        $scope.loadPage = function() {
            $scope.getCookies();
            $scope.pageLoaded = true;
            $scope.setisReady();
            $scope.setCookies();
            $scope.checkLoginType();
            $scope.checkForErrors();
        }

        $scope.setisReady();
        $scope.loadPage();

	}
	staticApp.register.controller('loginController', ['$scope', '$rootScope', '$location', '$cookies', '$stateParams', 'staticServices', loginController]);
});
