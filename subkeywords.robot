*** Settings ***

Library  Selenium2Library
Library  String
Library  DateTime
Library  Collections
Library  publicbid_service.py
Library  get_xpath.py


*** Keywords ***

Додати лоти
  [Arguments]  ${lots}
  ${lots_count}=    Get Length    ${lots}
  :FOR    ${index}    IN RANGE    0    ${lots_count}
  \  Input Text         xpath=//*[@id="mForm:lotTitle${index}"]    ${lots[${index}].title}
  \  Input Text         xpath=//*[@id="mForm:lotDesc${index}"]    ${lots[${index}].description}
  \  ${lots_budget}=    publicbid_service.convert_float_to_string    ${lots[${index}].value.amount}
  \  Input Text         xpath=//*[@id="mForm:lotBudg${index}"]    ${lots_budget}
  \  Click Element      xpath=(//*[@id='mForm:lotVat${index}']//span)[1]
  \  Sleep  30
  \  ${lots_step}=      publicbid_service.convert_float_to_string    ${lots[${index}].minimalStep.amount}
  \  Input Text         xpath=//*[@id='mForm:lotStep${index}']    ${lots_step}
  \  Sleep  2
  \  Run Keyword If    ${lots_count} != 1    Click Element    xpath=//span[text()='+']

Додати предмети
  [Arguments]  ${items}
  ${items_count}=    Get Length    ${items}
  :FOR    ${index}    IN RANGE    0    ${items_count}
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:subject']    ${items[${index}].description}
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cCpv_input']    ${items[${index}].classification.id}
  \  Wait Until Element Is Visible    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cCpv_panel']//td[1]    90
  \  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cCpv_panel']//td[1]
  \  ${dkpp_id}=                      Convert To String     000
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cDkpp_input']    ${dkpp_id}
  \  Wait Until Element Is Visible    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cDkpp_panel']//td[1]    90
  \  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cDkpp_panel']//td[1]
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:unit_input']    ${items[${index}].unit.code}
  \  Wait Until Element Is Visible    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:unit_panel']//td[1]    90
  \  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:unit_panel']//td[1]
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:amount']    ${items[${index}].quantity}
  \  ${delivery_start_date}=          Get From Dictionary    ${items[${index}].deliveryDate}    startDate
  \  ${delivery_start_date}=          publicbid_service.convert_item_date_to_string    ${delivery_start_date}
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delDS_input']    ${delivery_start_date}
  \  ${delivery_end_date}=            Get From Dictionary    ${items[${index}].deliveryDate}    endDate
  \  ${delivery_end_date}=            publicbid_service.convert_item_date_to_string  ${delivery_end_date}
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delDE_input']    ${delivery_end_date}
  \  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cReg_label']
  \  ${item_delivery_region}=         Get From Dictionary    ${items[${index}].deliveryAddress}    region
  \  ${item_delivery_region}=         publicbid_service.get_delivery_region    ${item_delivery_region}
  \  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cReg_items']/li[text()='${item_delivery_region}']
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cTer_input']    ${items[${index}].deliveryAddress.locality}
  \  Wait Until Element Is Visible    xpath=(//*[@id='mForm:lotItems${index}:lotItem_0:cTer_panel']//td[1])[1]    60
  \  Press Key                        xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cTer_input']    \\13
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:zc']    ${items[${index}].deliveryAddress.postalCode}
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delAdr']    ${items[${index}].deliveryAddress.streetAddress}
  \  ${latitude}=                     Get From Dictionary    ${items[${index}].deliveryLocation}    latitude
  \  ${latitude}=                     publicbid_service.convert_coordinates_to_string    ${latitude}
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delLoc1']    ${latitude}
  \  ${longitude}=                    Get From Dictionary    ${items[${index}].deliveryLocation}    longitude
  \  ${longitude}=                    publicbid_service.convert_coordinates_to_string    ${longitude}
  \  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delLoc2']    ${longitude}
  \  Execute JavaScript               window.scrollTo(0,1100)
  \  Sleep    2
  \  Run Keyword If    ${items_count} != 1    Click Element                    xpath=//span[text()='+']

Додати нецінові показники
  [Arguments]  ${prepared_tender_data}
  ${features}=               Get From Dictionary    ${prepared_tender_data}    features
  #Features for tender
  Click Element                    xpath=//*[@id='mForm:meatpanel']/button
  Wait Until Element Is Visible    xpath=//*[@id='mForm:bidF_0:meatTitle']    45
  Sleep  2
  Input Text                       xpath=//*[@id='mForm:bidF_0:meatTitle']    ${features[1].title}
  Sleep  2
  Input Text                       xpath=//*[@id='mForm:bidF_0:meat_comment']    ${features[1].description}
  Sleep  2
  :FOR    ${index}    IN RANGE    0    3
  \  ${index_xpath}=           publicbid_service.get_index_xpath    ${index}
  \  Wait Until Element Is Visible    xpath=(//*[@id='mForm:bidF_0:valuesTable_data']//td[1])[${index_xpath}]/div    45
  \  Click Element             xpath=(//*[@id='mForm:bidF_0:valuesTable_data']//td[1])[${index_xpath}]/div
  \  Clear Element Text        xpath=(//*[@id='mForm:bidF_0:valuesTable_data']//td[1])[${index_xpath}]//input
  \  Input Text                xpath=(//*[@id='mForm:bidF_0:valuesTable_data']//td[1])[${index_xpath}]//input    ${features[1].enum[${index}].title}
  \  Click Element             xpath=(//*[@id='mForm:bidF_0:valuesTable_data']//td[3])[${index_xpath}]/div
  \  Clear Element Text        xpath=(//*[@id='mForm:bidF_0:valuesTable_data']//td[3])[${index_xpath}]//input
  \  ${value}=                 publicbid_service.convert_float_to_string    ${features[1].enum[${index}].value}
  \  Input Text                xpath=(//*[@id='mForm:bidF_0:valuesTable_data']//td[3])[${index_xpath}]//input    ${value}
  \  Run Keyword If    ${index} != 2    Click Element    xpath=(//*[@id='mForm:bidF_0:valuesTable']//button)[1]

  #Features for lot
  Execute JavaScript                window.scrollTo(0, 2300)
  Sleep  1
  Click Element                     xpath=(//*[@id='mForm:lotItems0']//button)[4]
  Wait Until Element Is Visible     xpath=//*[@id='mForm:lotItems0:lotF_0_0:meatTitle']    45
  Sleep  2
  Input Text                        xpath=//*[@id='mForm:lotItems0:lotF_0_0:meatTitle']    ${features[0].title}
  Sleep  2
  Input Text                        xpath=//*[@id='mForm:lotItems0:lotF_0_0:meat_comment']    ${features[0].description}
  Sleep  2
  :FOR    ${index}    IN RANGE    0    3
  \  ${index_xpath}=          publicbid_service.get_index_xpath    ${index}
  \  Wait Until Element Is Visible    xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable_data']//td[1])[${index_xpath}]/div    30
  \  Click Element            xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable_data']//td[1])[${index_xpath}]/div
  \  Clear Element Text       xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable_data']//td[1])[${index_xpath}]//input
  \  Input Text               xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable_data']//td[1])[${index_xpath}]//input    ${features[0].enum[${index}].title}
  \  Click Element            xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable_data']//td[3])[${index_xpath}]/div
  \  Clear Element Text       xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable_data']//td[3])[${index_xpath}]//input
  \  ${value}=                publicbid_service.convert_float_to_string    ${features[0].enum[${index}].value}
  \  Input Text               xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable_data']//td[3])[${index_xpath}]//input    ${value}
  \  Run Keyword If    ${index} != 2    Click Element    xpath=(//*[@id='mForm:lotItems0:lotF_0_0:valuesTable']//button)[1]

  #Features for item
  Click Element                    xpath=(//*[@id='mForm:lotItems0']//button)[4]
  Wait Until Element Is Visible    xpath=//*[@id='mForm:lotItems0:lotF_0_1:cInd_label']    45
  Click Element                    xpath=//*[@id='mForm:lotItems0:lotF_0_1:cInd_label']
  Click Element                    xpath=//*[@id='mForm:lotItems0:lotF_0_1:cInd_1']
  Sleep  2
  Input Text                       xpath=//*[@id='mForm:lotItems0:lotF_0_1:meatTitle']    ${features[2].title}
  Sleep  2
  Input Text                       xpath=//*[@id='mForm:lotItems0:lotF_0_1:meat_comment']    ${features[2].description}
  Sleep  2
  :FOR    ${index}    IN RANGE    0    3
  \  ${index_xpath}=          publicbid_service.get_index_xpath    ${index}
  \  Wait Until Element Is Visible    xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable_data']//td[1])[${index_xpath}]/div    30
  \  Click Element            xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable_data']//td[1])[${index_xpath}]/div
  \  Clear Element Text       xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable_data']//td[1])[${index_xpath}]//input
  \  Input Text               xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable_data']//td[1])[${index_xpath}]//input    ${features[2].enum[${index}].title}
  \  Click Element            xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable_data']//td[3])[${index_xpath}]/div
  \  Clear Element Text       xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable_data']//td[3])[${index_xpath}]//input
  \  ${value}=                publicbid_service.convert_float_to_string    ${features[2].enum[${index}].value}
  \  Input Text               xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable_data']//td[3])[${index_xpath}]//input    ${value}
  \  Run Keyword If    ${index} !=2    Click Element    xpath=(//*[@id='mForm:lotItems0:lotF_0_1:valuesTable']//button)[1]

Додати дати до belowThreshold
  [Arguments]  ${prepared_tender_data}
  ${enquiry_period}=         Get From Dictionary    ${prepared_tender_data}                enquiryPeriod
  ${enquiry_period_end_date}=        publicbid_service.convert_date_to_string            ${enquiry_period.endDate}
  ${tender_period}=          Get From Dictionary    ${prepared_tender_data}                tenderPeriod
  ${tender_period_start_date}=    publicbid_service.convert_date_to_string  ${tender_period.startDate}
  Clear Element Text      id=mForm:dEA_input
  Input text              id=mForm:dEA_input    ${enquiry_period_end_date}
  Clear Element Text      id=mForm:dSPr_input
  Input text              id=mForm:dSPr_input    ${tender_period_start_date}

Змінити дату
  [Arguments]  ${fieldvalue}
  Clear Element Text    xpath=//*[@id='mForm:dEPr_input']
  ${endDate}=           publicbid_service.convert_date_to_string    ${fieldvalue}
  Input Text            xpath=//*[@id='mForm:dEPr_input']    ${endDate}

Змінити опис
  [Arguments]  ${fieldvalue}
  Clear Element Text    xpath=//*[@id='mForm:desc']
  Input Text            xpath=//*[@id='mForm:desc']    ${fieldvalue}
  Sleep  120

Отримати дані з поля item
  [Arguments]  ${field}  ${item_id}
  ${field_xpath}=    get_xpath.get_item_xpath    ${field}    ${item_id}
  ${type_field}=    publicbid_service.get_type_field    ${field}
  ${value} =  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
    ...     ELSE IF             '${type_field}' == 'text'    Get Text    ${field_xpath}
  [return]  ${value}

Адаптувати дані з поля item
  [Arguments]  ${field}  ${value}
  ${value}=  Run Keyword If    '${field}' == 'unit.name'    publicbid_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'unit.code'    publicbid_service.get_unit    ${field}    ${value}
    ...      ELSE IF           '${field}' == 'quantity'     Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.latitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryLocation.longitude'    Convert To Number    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.startDate'    publicbid_service.parse_item_date    ${value}
    ...      ELSE IF           '${field}' == 'deliveryDate.endDate'    publicbid_service.parse_item_date    ${value}
    ...      ELSE IF           '${field}' == 'classification.scheme'    Get Scheme    ${value}
    ...      ELSE               Set Variable    ${value}
  [return]  ${value}

Отримати дані з поля lot
  [Arguments]  ${field}  ${lot_id}  ${mode}
  ${field_xpath}=    get_xpath.get_lot_xpath    ${field}    ${lot_id}    ${mode}
  ${type_field}=    publicbid_service.get_type_field    ${field}
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...        ELSE IF           '${type_field}' == 'text'    Get Text    ${field_xpath}
  [return]  ${value}

Адаптувати дані з поля lot
  [Arguments]  ${field}  ${value}
  ${value}=  Run Keyword If    '${field}' == 'value.amount'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'minimalStep.amount'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'value.currency'    publicbid_service.convert_data_lot    ${value}
  ...        ELSE IF           '${field}' == 'minimalStep.currency'    publicbid_service.convert_data_lot    ${value}
  ...        ELSE IF           '${field}' == 'value.valueAddedTaxIncluded'    Convert To Boolean    True
  ...        ELSE IF           '${field}' == 'minimalStep.valueAddedTaxIncluded'    Convert To Boolean    True
  ...        ELSE              Set Variable    ${value}
  [return]  ${value}

Отримати дані з поля feature
  [Arguments]  ${field_name}  ${feature_id}
  ${field_xpath}=    get_xpath.get_feature_xpath    ${field_name}  ${feature_id}
  ${type_field}=    publicbid_service.get_type_field    ${field_name}
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...        ELSE IF           '${type_field}' == 'text'    Get Text    ${field_xpath}
  [return]  ${value}

Get Scheme
  [Arguments]  ${value}
  ${value}=    Get Substring    ${value}    36    38
  ${value}=    Replace String    ${value}    ДК    CPV
  [return]  ${value}

Wait For Question
  [Arguments]  ${field_xpath}
  Reload page
  Sleep  3
  Page Should Contain Element    xpath=${field_xpath}

Wait For TenderPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[text()='Очікування пропозицій']

Wait For AuctionPeriod
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[text()='Період аукціону']

Wait For NewLot
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[@id='lotTabButton_2']

Wait For NewItem
  [Arguments]  ${item_id}
  Reload Page
  Sleep  3
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//*[@id='lotTabButton_2']
  Sleep  2
  Page Should Contain Element    xpath=//*[contains(text(), '${item_id}')]

Wait For NewFeature
  [Arguments]  ${feature_id}
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[contains(@value, '${feature_id}')]

Wait For Document
  [Arguments]  ${field_xpath}
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=${field_xpath}

Wait For ClaimTender
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]

Wait For ClaimLot
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[2]

Wait For Answered
  Reload Page
  Sleep  5
  Page Should Contain Element    xpath=//*[@id='mForm:data:resolutionType_label']

Wait For Satisfied
  Reload Page
  Sleep  5
  Page Should Contain Element    xpath=//*[@id='mForm:data:satisfied_label']

Wait For Cancelled
  Reload Page
  Sleep  5
  Page Should Contain Element    xpath=//*[text()='Відхилено']

Wait For EndEnquire
  Reload Page
  Sleep  3
  Page Should Not Contain Element    xpath=//*[text()='Очікування пропозицій']

Wait For Status
  Reload Page
  Sleep  3
  Page Should Contain Element    xpath=//*[text()='Недійсна пропозиція']


Switch new lot
  [Arguments]  ${username}  ${tender_uaid}
  publicbid.Пошук тендера по ідентифікатору    ${username}  ${tender_uaid}
  Wait Until Keyword Succeeds    180 s    10 s    subkeywords.Wait For NewLot
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//*[@id='lotTabButton_2']
  Sleep  2

Подати цінову пропозицію для open
  [Arguments]  ${bid}  ${lots_ids}  ${features_ids}

  ${number_lots}=    Get Length    ${bid.data.lotValues}
  ${meat}=  Evaluate  ${tender_meat} + ${lot_meat} + ${item_meat}
  ${lot_ids}=  Run Keyword If  ${lots_ids}  Set Variable  ${lots_ids}
  ...    ELSE  Create List
  Set Suite Variable    @{ID}    ${lot_ids}

  :FOR  ${index}  ${lot_id}  IN ENUMERATE  @{lot_ids}
  \  Execute JavaScript                window.scrollTo(0, 500)
  \  Sleep  1
  \  Click Element    xpath=(//span[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]//button/span)[1]
  \  Sleep  3
  \  ${amount}=    publicbid_service.convert_float_to_string    ${bid.data.lotValues[${index}].value.amount}
  \  Input Text    xpath=//span[contains(text(), '${lot_id}')]//ancestor::div[2]/div[2]/table/tbody/tr[7]/td[2]//input    ${amount}

  Run Keyword If    ${meat} > 0    subkeywords.Обрати неціновий показник    ${bid}    ${features_ids}

  Execute JavaScript   window.scrollTo(0, 0)
  Click Element    xpath=(//*[@id='mForm:data:selfQualified']//span[1])[1]
  Click Element    xpath=//*[@id='mForm:data:selfEligible']/div[2]/span

Подати цінову пропозицію для below
  [Arguments]  ${bid}
  Wait Until Element Is Visible    xpath=//*[@id='mForm:data:amount']    30
  ${amount}=    publicbid_service.convert_float_to_string    ${bid.data.value.amount}
  Input Text    xpath=//*[@id='mForm:data:amount']    ${amount}

Обрати неціновий показник
  [Arguments]  ${bid}  ${features_ids}
  ${numbers_feature}=  Get Length  ${bid.data.parameters}
  ${features_ids}=  Run Keyword If  ${features_ids}  Set Variable  ${features_ids}
  ...    ELSE  Create List
  :FOR  ${index}  ${feature_id}  IN ENUMERATE  @{features_ids}
  \  ${feature_of}=    Get Text    xpath=//*[contains(text(), '${feature_id}')]//ancestor::tbody/tr[2]/td[2]/label
  \  ${pos}=    publicbid_service.get_pos    ${feature_of}
  \  ${value}=    publicbid_service.get_value_feature    ${bid.data.parameters[${index}]['value']}
  \  Run Keyword If    '${feature_of}' == 'Закупівлі'    Execute JavaScript   window.scrollTo(0, 100)
  \  Run Keyword If    '${feature_of}' == 'Предмету лоту'    Execute JavaScript   window.scrollTo(0, 1600)
  \  Click Element    xpath=//*[contains(text(), '${feature_id}')]//ancestor::tbody/tr[4]/td[2]/div
  \  Sleep  3
  \  Click Element    xpath=(//*[contains(text(), '${value}') and @class='ui-selectonemenu-item ui-selectonemenu-list-item ui-corner-all'])[${pos}]


Отримати дані з bid below
  ${value}=    Get value    xpath=//*[@id='mForm:data:amount']
  ${value}=    Convert To Number    ${value}
  [return]  ${value}


Отримати дані з bid open
  [Arguments]  ${field}
  ${xpath}=    get_xpath.get_bid_xpath    ${field}    @{ID}
  ${value}=  Run Keyword If    '${field}' != 'status'    Get Value    xpath=${xpath}
  ...        ELSE IF           '${field}' == 'status'    Get Text    xpath=${xpath}
  ${return_value}=  Run Keyword If    '${field}' != 'status'    Convert To Number    ${value}
  ...        ELSE IF           '${field}' == 'status'    publicbid_service.convert_bid_status    ${value}
  [return]  ${return_value}


Змінити цінову пропозицію below
  [Arguments]  ${fieldvalue}
  ${value}=    Convert To String    ${fieldvalue}
  Clear Element Text    xpath=//*[@id='mForm:data:amount']
  Sleep  1
  Input Text    xpath=//*[@id='mForm:data:amount']    ${value}
  Sleep  2
  Click Element    xpath=//span[text()='Зберегти']
  Sleep  15


Змінити цінову пропозицію open
  [Arguments]  ${fieldname}  ${fieldvalue}
  Run Keyword If    '${fieldname}' == 'status'    subkeywords.Підтвердити пропозицію
  Run Keyword If    '${fieldname}' != 'status'    subkeywords.Змінити ставку    ${fieldname}    ${fieldvalue}


Змінити ставку
  [Arguments]  ${fieldname}  ${fieldvalue}
  ${xpath}=    get_xpath.get_bid_xpath    ${fieldname}    @{ID}
  ${value}=    Convert To String    ${fieldvalue}
  Clear Element Text    xpath=${xpath}
  Sleep  1
  Input Text    xpath=${xpath}    ${value}
  Sleep  2
  Click Element    xpath=//span[text()='Зберегти']
  Sleep  15


Підтвердити пропозицію
  Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
  Click Element    xpath=//*[text()='Підтвердити пропозицію']
  Sleep  30





