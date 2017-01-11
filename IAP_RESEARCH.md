# ERROR CODES:
  ITC.response.error.IAP_DELETION_NOT_ALLOWED -> delete of iap on sale

# GET auto Renew Pricing Block:
  (TIER)
  https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps/1195440565/pricing/equalize/EUR/1



# CREATE NON RENEW SUBSCRIPTION:
POST: https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps

{
  "sectionErrorKeys": [
    
  ],
  "sectionInfoKeys": [
    
  ],
  "sectionWarningKeys": [
    
  ],
  "id": null,
  "adamId": null,
  "appAdamIds": null,
  "familyId": null,
  "addOnType": "subscription",
  "isNewsSubscription": false,
  "isReplaced": false,
  "replacementAdamId": null,
  "referenceName": {
    "value": "verweisname",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 64,
    "minLength": 2
  },
  "productId": {
    "value": "produkt.id.non.renew",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 100,
    "minLength": 2
  },
  "clearedForSale": {
    "value": true,
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "pricingDurationType": null,
  "pricingIntervals": [
    {
      "value": {
        "country": "WW",
        "grandfathered": null,
        "priceTierEffectiveDate": null,
        "priceTierEndDate": null,
        "tierStem": "1"
      }
    }
  ],
  "ungrandfatheredIntervals": null,
  "freeTrialDurationType": null,
  "bonusPeriodDurationType": null,
  "versions": [
    {
      "id": null,
      "details": {
        "value": [
          {
            "value": {
              "id": null,
              "name": {
                "value": "anzeige name non renew",
                "isEditable": true,
                "isRequired": true,
                "errorKeys": null,
                "maxLength": 75,
                "minLength": 2
              },
              "description": {
                "value": "non-renew anzeigename ........",
                "isEditable": true,
                "isRequired": false,
                "errorKeys": null,
                "maxLength": 255,
                "minLength": 10
              },
              "publicationName": null,
              "localeCode": "en-US",
              "status": null
            },
            "isEditable": true,
            "isRequired": false,
            "errorKeys": null,
            "isDeletable": true
          }
        ],
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "contentHosting": null,
      "contentHostingData": null,
      "reviewNotes": {
        "value": "",
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null,
        "maxLength": 4000,
        "minLength": 2
      },
      "reviewScreenshot": {
        "value": {
          "assetToken": null,
          "sortOrder": null,
          "type": null,
          "size": null,
          "width": null,
          "height": null,
          "checksum": null,
          "url": null,
          "thumbNailUrl": null,
          "originalFileName": null
        },
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "status": null,
      "canBeSubmitted": false
    }
  ],
  "missingRequiredPrivacyPolicyData": false,
  "missingRequiredFamilyDetail": false
}

# MODIFY Non-Renew Subscription:

PUT https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps/1195370290

{
  "sectionErrorKeys": [
    
  ],
  "sectionInfoKeys": [
    
  ],
  "sectionWarningKeys": [
    
  ],
  "id": "3121657399",
  "adamId": "1195370290",
  "appAdamIds": [
    "1173658173"
  ],
  "familyId": null,
  "addOnType": "subscription",
  "isNewsSubscription": false,
  "isReplaced": false,
  "replacementAdamId": null,
  "referenceName": {
    "value": "verweisname123",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 64,
    "minLength": 2
  },
  "productId": {
    "value": "produkt.id.non.renew",
    "isEditable": false,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 100,
    "minLength": 2
  },
  "clearedForSale": {
    "value": true,
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "pricingDurationType": null,
  "pricingIntervals": [
    {
      "value": {
        "tierStem": "1",
        "priceTierEffectiveDate": null,
        "priceTierEndDate": null,
        "country": "WW",
        "grandfathered": null
      },
      "isEditable": true,
      "isRequired": false,
      "errorKeys": null
    }
  ],
  "ungrandfatheredIntervals": null,
  "freeTrialDurationType": null,
  "bonusPeriodDurationType": null,
  "versions": [
    {
      "id": "95813995",
      "details": {
        "value": [
          {
            "value": {
              "id": "101363471",
              "name": {
                "value": "anzeige name non renew",
                "isEditable": true,
                "isRequired": true,
                "errorKeys": null,
                "maxLength": 75,
                "minLength": 2
              },
              "description": {
                "value": "non-renew anzeigename ........",
                "isEditable": true,
                "isRequired": false,
                "errorKeys": null,
                "maxLength": 255,
                "minLength": 10
              },
              "publicationName": null,
              "localeCode": "en-US",
              "status": "proposed"
            },
            "isEditable": true,
            "isRequired": false,
            "errorKeys": null,
            "isDeletable": true
          }
        ],
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "contentHosting": null,
      "contentHostingData": null,
      "reviewNotes": {
        "value": null,
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null,
        "maxLength": 4000,
        "minLength": 2
      },
      "reviewScreenshot": {
        "value": {
          "assetToken": null,
          "sortOrder": null,
          "type": null,
          "size": null,
          "width": null,
          "height": null,
          "checksum": null,
          "url": null,
          "thumbNailUrl": null,
          "originalFileName": null
        },
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "status": "missingMetadata",
      "canBeSubmitted": false
    }
  ],
  "missingRequiredPrivacyPolicyData": false,
  "missingRequiredFamilyDetail": false
}



# MODIFY Auto-Renew-Subscription:
PUT https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps/1195370281

{
  "sectionErrorKeys": [
    
  ],
  "sectionInfoKeys": [
    
  ],
  "sectionWarningKeys": [
    
  ],
  "id": "3121657398",
  "adamId": "1195370281",
  "appAdamIds": [
    "1173658173"
  ],
  "familyId": "20372172",
  "addOnType": "recurring",
  "isNewsSubscription": false,
  "isReplaced": false,
  "replacementAdamId": null,
  "referenceName": {
    "value": "Auto-Renew-referenceName",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 64,
    "minLength": 2
  },
  "productId": {
    "value": "auto.renew.ref",
    "isEditable": false,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 100,
    "minLength": 2
  },
  "clearedForSale": {
    "value": false,
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "pricingDurationType": {
    "value": "1w",
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "pricingIntervals": [
    
  ],
  "ungrandfatheredIntervals": [
    
  ],
  "freeTrialDurationType": {
    "value": "1w",
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "bonusPeriodDurationType": null,
  "versions": [
    {
      "id": "95813993",
      "details": {
        "value": [
          
        ],
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "contentHosting": null,
      "contentHostingData": null,
      "reviewNotes": {
        "value": null,
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null,
        "maxLength": 4000,
        "minLength": 2
      },
      "reviewScreenshot": {
        "value": {
          "assetToken": null,
          "sortOrder": null,
          "type": null,
          "size": null,
          "width": null,
          "height": null,
          "checksum": null,
          "url": null,
          "thumbNailUrl": null,
          "originalFileName": null
        },
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "status": "missingMetadata",
      "canBeSubmitted": false
    }
  ],
  "missingRequiredPrivacyPolicyData": true,
  "missingRequiredFamilyDetail": true
}


# CREATE Auto-Renew-Subscription:
POST - https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps/family/
{
  "sectionErrorKeys": [
    
  ],
  "sectionInfoKeys": [
    
  ],
  "sectionWarningKeys": [
    
  ],
  "name": {
    "value": "GROUP NAME FAMILY",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 64,
    "minLength": 2
  },
  "id": null,
  "activeAddOns": [
    {
      "adamId": null,
      "productId": {
        "value": "auto.renew.ref",
        "isEditable": true,
        "isRequired": true,
        "errorKeys": null,
        "maxLength": 100,
        "minLength": 2
      },
      "familyRank": {
        "value": null,
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "iTunesConnectStatus": null,
      "referenceName": {
        "value": "Auto-Renew-referenceName",
        "isEditable": true,
        "isRequired": true,
        "errorKeys": null,
        "maxLength": 64,
        "minLength": 2
      },
      "pricingDurationType": {
        "value": null,
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      }
    }
  ],
  "totalActiveAddOns": 0,
  "replacementFamilyId": null,
  "details": {
    "value": [
      
    ],
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  }
}




# upload screenshot - Request
https://du-itc.itunes.apple.com/upload/image

# upload screenshot - Response
{
  "token" : "Purple122/v4/ec/1f/ec/ec1fec20-fc89-e40e-539b-a50246c8f6bb/pr_source.png",
  "tokenType" : "AssetToken",
  "type" : "MZSortedScreenShotImageType.SOURCE",
  "width" : 640,
  "height" : 920,
  "hasAlpha" : false,
  "length" : 31936,
  "md5" : "d41d8cd98f00b204e9800998ecf8427e"
}

# show shared secret
https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/addons/sharedSecret/

{
  "data": "xxxxx",
  "messages": {
    "warn": null,
    "error": null,
    "info": [
      "Shared secret has been fetched for KroneMultimediaGmbHCoKG"
    ]
  },
  "statusCode": "SUCCESS"
}
✔


# DELETE IAP
DELETE https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps/1194162852

{
  "data": null,
  "messages": {
    "warn": null,
    "info": [
      "association between addon: 1194162852 and software: 1173658173 has been removed."
    ],
    "error": null
  },
  "statusCode": null
}
✔

# LIST IAP - Query
https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps

{
  "data": [
    {
      "adamId": "1194155181",
      "referenceName": "verweisname",
      "familyReferenceName": null,
      "vendorId": "at.ipa.descr.id",
      "addOnType": "ITC.addons.type.consumable",
      "durationDays": 0,
      "versions": [
        {
          "screenshotUrl": null,
          "canSubmit": true,
          "issuesCount": 0,
          "itunesConnectStatus": "readyToSubmit"
        }
      ],
      "purpleSoftwareAdamIds": [
        "1173658173"
      ],
      "lastModifiedDate": 1484166365000,
      "isNewsSubscription": false,
      "numberOfCodes": 0,
      "maximumNumberOfCodes": 100,
      "appMaximumNumberOfCodes": 1000,
      "isEditable": false,
      "isRequired": false,
      "canDeleteAddOn": true,
      "errorKeys": null,
      "itcsubmitNextVersion": false,
      "isEmptyValue": false,
      "iTunesConnectStatus": "readyToSubmit"
    }
  ],
  "messages": {
    "warn": null,
    "error": null,
    "info": null
  },
  "statusCode": "SUCCESS"
}



# MODIFY IAP - Response
{
"data": {
  "sectionErrorKeys": [
    
  ],
  "sectionInfoKeys": [
    
  ],
  "sectionWarningKeys": [
    
  ],
  "id": "3120465023",
  "adamId": "1194155181",
  "appAdamIds": [
    "1173658173"
  ],
  "familyId": null,
  "addOnType": "consumable",
  "isNewsSubscription": false,
  "isReplaced": false,
  "replacementAdamId": null,
  "referenceName": {
    "value": "verweisname",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 64,
    "minLength": 2
  },
  "productId": {
    "value": "at.ipa.descr.id",
    "isEditable": false,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 100,
    "minLength": 2
  },
  "clearedForSale": {
    "value": true,
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "pricingDurationType": null,
  "pricingIntervals": [
    {
      "value": {
        "tierStem": "1",
        "priceTierEffectiveDate": null,
        "priceTierEndDate": null,
        "country": "WW",
        "grandfathered": null
      },
      "isEditable": true,
      "isRequired": false,
      "errorKeys": null
    }
  ],
  "ungrandfatheredIntervals": null,
  "freeTrialDurationType": null,
  "bonusPeriodDurationType": null,
  "versions": [
    {
      "id": "95793735",
      "details": {
        "value": [
          {
            "value": {
              "id": "101332955",
              "name": {
                "value": "testname",
                "isEditable": true,
                "isRequired": true,
                "errorKeys": null,
                "maxLength": 75,
                "minLength": 2
              },
              "description": {
                "value": "testdescgdfdfg dfg dfg dfg",
                "isEditable": true,
                "isRequired": false,
                "errorKeys": null,
                "maxLength": 255,
                "minLength": 10
              },
              "publicationName": null,
              "localeCode": "en-US",
              "status": "proposed"
            },
            "isEditable": true,
            "isRequired": false,
            "errorKeys": null,
            "isDeletable": true
          }
        ],
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "contentHosting": null,
      "contentHostingData": null,
      "reviewNotes": {
        "value": "review notes",
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null,
        "maxLength": 4000,
        "minLength": 2
      },
      "reviewScreenshot": {
        "value": {
          "assetToken": "Purple122\/v4\/ec\/1f\/ec\/ec1fec20-fc89-e40e-539b-a50246c8f6bb\/pr_source.png",
          "sortOrder": 0,
          "type": "SortedScreenShot",
          "size": 31936,
          "width": 640,
          "height": 920,
          "checksum": "d41d8cd98f00b204e9800998ecf8427e",
          "url": "https:\/\/is5-ssl.mzstatic.com\/image\/thumb\/Purple122\/v4\/ec\/1f\/ec\/ec1fec20-fc89-e40e-539b-a50246c8f6bb\/pr_source.png\/640x920ss-80.png",
          "thumbNailUrl": "https:\/\/is3-ssl.mzstatic.com\/image\/thumb\/Purple122\/v4\/ec\/1f\/ec\/ec1fec20-fc89-e40e-539b-a50246c8f6bb\/pr_source.png\/340x340bb-80.png",
          "originalFileName": "iapscreen.png"
        },
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "status": "readyToSubmit",
      "canBeSubmitted": true
    }
  ],
  "missingRequiredPrivacyPolicyData": false,
  "missingRequiredFamilyDetail": false
},
"messages": {
  "warn": null,
  "error": null,
  "info": [
    "Successfully updated"
  ]
},
"statusCode": "SUCCESS"
}

# GET IAP details
https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps/1194155181
{
  "data": {
    "sectionErrorKeys": [
      
    ],
    "sectionInfoKeys": [
      
    ],
    "sectionWarningKeys": [
      
    ],
    "id": "3120465023",
    "adamId": "1194155181",
    "appAdamIds": [
      "1173658173"
    ],
    "familyId": null,
    "addOnType": "consumable",
    "isNewsSubscription": false,
    "isReplaced": false,
    "replacementAdamId": null,
    "referenceName": {
      "value": "verweisname",
      "isEditable": true,
      "isRequired": true,
      "errorKeys": null,
      "maxLength": 64,
      "minLength": 2
    },
    "productId": {
      "value": "at.ipa.descr.id",
      "isEditable": false,
      "isRequired": true,
      "errorKeys": null,
      "maxLength": 100,
      "minLength": 2
    },
    "clearedForSale": {
      "value": true,
      "isEditable": true,
      "isRequired": false,
      "errorKeys": null
    },
    "pricingDurationType": null,
    "pricingIntervals": [
      {
        "value": {
          "tierStem": "1",
          "priceTierEffectiveDate": null,
          "priceTierEndDate": null,
          "country": "WW",
          "grandfathered": null
        },
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      }
    ],
    "ungrandfatheredIntervals": null,
    "freeTrialDurationType": null,
    "bonusPeriodDurationType": null,
    "versions": [
      {
        "id": "95793735",
        "details": {
          "value": [
            {
              "value": {
                "id": "101332955",
                "name": {
                  "value": "testname",
                  "isEditable": true,
                  "isRequired": true,
                  "errorKeys": null,
                  "maxLength": 75,
                  "minLength": 2
                },
                "description": {
                  "value": "testdescgdfdfg dfg dfg dfg",
                  "isEditable": true,
                  "isRequired": false,
                  "errorKeys": null,
                  "maxLength": 255,
                  "minLength": 10
                },
                "publicationName": null,
                "localeCode": "en-US",
                "status": "proposed"
              },
              "isEditable": true,
              "isRequired": false,
              "errorKeys": null,
              "isDeletable": true
            }
          ],
          "isEditable": true,
          "isRequired": false,
          "errorKeys": null
        },
        "contentHosting": null,
        "contentHostingData": null,
        "reviewNotes": {
          "value": "review notes",
          "isEditable": true,
          "isRequired": false,
          "errorKeys": null,
          "maxLength": 4000,
          "minLength": 2
        },
        "reviewScreenshot": {
          "value": {
            "assetToken": "Purple122\/v4\/ec\/1f\/ec\/ec1fec20-fc89-e40e-539b-a50246c8f6bb\/pr_source.png",
            "sortOrder": 0,
            "type": "SortedScreenShot",
            "size": 31936,
            "width": 640,
            "height": 920,
            "checksum": "d41d8cd98f00b204e9800998ecf8427e",
            "url": "https:\/\/is5-ssl.mzstatic.com\/image\/thumb\/Purple122\/v4\/ec\/1f\/ec\/ec1fec20-fc89-e40e-539b-a50246c8f6bb\/pr_source.png\/640x920ss-80.png",
            "thumbNailUrl": "https:\/\/is3-ssl.mzstatic.com\/image\/thumb\/Purple122\/v4\/ec\/1f\/ec\/ec1fec20-fc89-e40e-539b-a50246c8f6bb\/pr_source.png\/340x340bb-80.png",
            "originalFileName": "iapscreen.png"
          },
          "isEditable": true,
          "isRequired": false,
          "errorKeys": null
        },
        "status": "readyToSubmit",
        "canBeSubmitted": true
      }
    ],
    "missingRequiredPrivacyPolicyData": false,
    "missingRequiredFamilyDetail": false
  },
  "messages": {
    "warn": null,
    "error": null,
    "info": null
  },
  "statusCode": "SUCCESS"
}
✔



# MODIFY IAP - Request
PUT https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps/1194155181


{
  "sectionErrorKeys": [
    
  ],
  "sectionInfoKeys": [
    
  ],
  "sectionWarningKeys": [
    
  ],
  "id": "3120465023",
  "adamId": "1194155181",
  "appAdamIds": [
    "1173658173"
  ],
  "familyId": null,
  "addOnType": "consumable",
  "isNewsSubscription": false,
  "isReplaced": false,
  "replacementAdamId": null,
  "referenceName": {
    "value": "verweisname",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 64,
    "minLength": 2
  },
  "productId": {
    "value": "at.ipa.descr.id",
    "isEditable": false,
    "isRequired": true,
    "errorKeys": null,
    "maxLength": 100,
    "minLength": 2
  },
  "clearedForSale": {
    "value": true,
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "pricingDurationType": null,
  "pricingIntervals": [
    {
      "value": {
        "tierStem": "1",
        "priceTierEffectiveDate": null,
        "priceTierEndDate": null,
        "country": "WW",
        "grandfathered": null
      },
      "isEditable": true,
      "isRequired": false,
      "errorKeys": null
    }
  ],
  "ungrandfatheredIntervals": null,
  "freeTrialDurationType": null,
  "bonusPeriodDurationType": null,
  "versions": [
    {
      "id": "95793735",
      "details": {
        "value": [
          {
            "value": {
              "id": "101332955",
              "name": {
                "value": "testname",
                "isEditable": true,
                "isRequired": true,
                "errorKeys": null,
                "maxLength": 75,
                "minLength": 2
              },
              "description": {
                "value": "testdescgdfdfg dfg dfg dfg",
                "isEditable": true,
                "isRequired": false,
                "errorKeys": null,
                "maxLength": 255,
                "minLength": 10
              },
              "publicationName": null,
              "localeCode": "en-US",
              "status": "proposed"
            },
            "isEditable": true,
            "isRequired": false,
            "errorKeys": null,
            "isDeletable": true
          }
        ],
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "contentHosting": null,
      "contentHostingData": null,
      "reviewNotes": {
        "value": "review notes",
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null,
        "maxLength": 4000,
        "minLength": 2
      },
      "reviewScreenshot": {
        "value": {
          "assetToken": "Purple122\/v4\/ec\/1f\/ec\/ec1fec20-fc89-e40e-539b-a50246c8f6bb\/pr_source.png",
          "sortOrder": null,
          "type": "MZPFT.SortedScreenShot",
          "size": 31936,
          "width": 640,
          "height": 920,
          "checksum": "d41d8cd98f00b204e9800998ecf8427e",
          "url": null,
          "thumbNailUrl": null,
          "originalFileName": "iapscreen.png"
        },
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "status": "missingMetadata",
      "canBeSubmitted": false
    }
  ],
  "missingRequiredPrivacyPolicyData": false,
  "missingRequiredFamilyDetail": false
}



# CREATE IAP - RESPONSE
{
  "data": null,
  "messages": {
    "warn": null,
    "error": null,
    "info": [
      "Successfully created new IAP"
    ]
  },
  "statusCode": "SUCCESS"
}

# CREATE IAP  - REQUEST

app.create_purchase!(type: "consumable", 
                      versions: {
                        'en-US': {
                          name: "test name1",
                          description: "Description has at least 10 characters"
                        },
                        'de-DE': {
                          name: "test name german1",
                          description: "German has at least 10 characters"
                        }
                      },
                      
                      reference_name: "locallizeddemo",
                      product_id: "x.a.a.b.b.c.d.x.y.z",
                      cleared_for_sale: true,
                      review_notes: "Some Review Notes here bla bla bla",
                      review_screenshot: nil, 
                      tier: 1
)



POST https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1173658173/iaps

{
  "sectionErrorKeys": [
    "Die Beschreibung muss mindestens 10 Zeichen umfassen."
  ],
  "sectionInfoKeys": [
    
  ],
  "sectionWarningKeys": [
    
  ],
  "id": null,
  "adamId": null,
  "appAdamIds": null,
  "familyId": null,
  "addOnType": "consumable",
  "isNewsSubscription": false,
  "isReplaced": false,
  "replacementAdamId": null,
  "referenceName": {
    "value": "verweisname",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": [
      
    ],
    "maxLength": 64,
    "minLength": 2
  },
  "productId": {
    "value": "at.ipa.descr.id",
    "isEditable": true,
    "isRequired": true,
    "errorKeys": [
      
    ],
    "maxLength": 100,
    "minLength": 2
  },
  "clearedForSale": {
    "value": true,
    "isEditable": true,
    "isRequired": false,
    "errorKeys": null
  },
  "pricingDurationType": null,
  "pricingIntervals": [
    {
      "value": {
        "country": "WW",
        "grandfathered": null,
        "priceTierEffectiveDate": null,
        "priceTierEndDate": null,
        "tierStem": "1"
      }
    }
  ],
  "ungrandfatheredIntervals": null,
  "freeTrialDurationType": null,
  "bonusPeriodDurationType": null,
  "versions": [
    {
      "id": null,
      "details": {
        "value": [
          {
            "value": {
              "id": null,
              "name": {
                "value": "testname",
                "isEditable": true,
                "isRequired": true,
                "errorKeys": [
                  
                ],
                "maxLength": 75,
                "minLength": 2
              },
              "description": {
                "value": "testdescgdfdfg dfg dfg dfg",
                "isEditable": true,
                "isRequired": false,
                "errorKeys": [
                  "Die Beschreibung muss mindestens 10 Zeichen umfassen."
                ],
                "maxLength": 255,
                "minLength": 10
              },
              "publicationName": null,
              "localeCode": "en-US",
              "status": null
            },
            "isEditable": true,
            "isRequired": false,
            "errorKeys": null,
            "isDeletable": true
          }
        ],
        "isEditable": true,
        "isRequired": false,
        "errorKeys": null
      },
      "contentHosting": null,
      "contentHostingData": null,
      "reviewNotes": {
        "value": "review notes",
        "isEditable": true,
        "isRequired": false,
        "errorKeys": [
          
        ],
        "maxLength": 4000,
        "minLength": 2
      },
      "reviewScreenshot": {
        "value": null,
        "isEditable": true,
        "isRequired": false,
        "errorKeys": [
          
        ]
      },
      "status": null,
      "canBeSubmitted": false
    }
  ],
  "missingRequiredPrivacyPolicyData": false,
  "missingRequiredFamilyDetail": false
}
✔
