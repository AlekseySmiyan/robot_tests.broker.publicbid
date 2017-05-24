*** Settings ***

Library  Selenium2Library
Library  String
Library  DateTime
Library  publicbid_service.py
Library  get_xpath.py
Resource  subkeywords.robot
Resource  view.robot

*** Variables ***

${mail}          test_test@test.com
${telephone}     +380630000000
${bid_number}
${auction_url}

*** Keywords ***

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${adapted_data}=  Run Keyword If  '${username}' == 'Publicbid_Owner'
  ...    publicbid_service.adapt_data    ${tender_data}
  ...    ELSE    publicbid_service.adapt_data_view    ${tender_data}
  [return]  ${adapted_data}


Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser   ${USERS.users['${ARGUMENTS[0]}'].homepage}   ${USERS.users['${ARGUMENTS[0]}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'Publicbid_Viewer'   Вхід  ${ARGUMENTS[0]}


Вхід
  [Arguments]  ${username}
  Run Keyword And Ignore Error   Wait Until Page Contains Element    xpath=//*[text()='Вхід']   30
  Click Element                      xpath=//*[text()='Вхід']
  Run Keyword And Ignore Error   Wait Until Page Contains Element   id=mForm:email   20
  Input text   id=mForm:email      ${USERS.users['${username}'].login}
  Sleep  2
  Input text   id=mForm:pwd      ${USERS.users['${username}'].password}
  Click Button   id=mForm:login
  Sleep  3
  ${status}=   Run Keyword And Return Status   Page Should Contain Element   id=mForm:j_idt121
  Run Keyword if   '${status}' == 'True'
  ...  Run Keywords
  ...    Wait Until Element Is Visible  id=mForm:j_idt123  30
  ...    AND  Click Element  id=mForm:j_idt123


#                                    TENDER OPERATIONS                                           #

Створити тендер
  [Arguments]  ${username}  ${tender_data}
  ${prepared_tender_data}=   Get From Dictionary    ${tender_data}                       data
  ${lots}=                   Get From Dictionary    ${prepared_tender_data}               lots
  ${items}=                  Get From Dictionary    ${prepared_tender_data}               items
  #${features}=               Get From Dictionary    ${prepared_tender_data}               features
  ${title}=                  Get From Dictionary    ${prepared_tender_data}               title
  ${title_en}=               Get From Dictionary    ${prepared_tender_data}               title_en
  ${description}=            Get From Dictionary    ${prepared_tender_data}               description
  ${description_en}=         Get From Dictionary    ${prepared_tender_data}               description_en

  #${budget}=                 Get From Dictionary    ${prepared_tender_data.value}         amount
  #${budget}=                 publicbid_service.convert_float_to_string                    ${budget}
  #${step_rate}=              Get From Dictionary    ${prepared_tender_data.minimalStep}   amount
  #${step_rate}=              publicbid_service.convert_float_to_string                    ${step_rate}
  #${enquiry_period}=         Get From Dictionary   ${prepared_tender_data}                enquiryPeriod
  #${enquiry_period_end_date}=        publicbid_service.convert_date_to_string            ${enquiry_period.endDate}
  ${tender_period}=          Get From Dictionary   ${prepared_tender_data}                tenderPeriod
  ${tender_period_start_date}=    publicbid_service.convert_date_to_string  ${tender_period.startDate}
  ${tender_period_end_date}=  publicbid_service.convert_date_to_string  ${tender_period.endDate}
  ${countryName}=    Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=    Get From Dictionary    ${items[0]}    description
  #${item_description_en}=    Get From Dictionary    ${items[0]}    description_en
  #${delivery_start_date}=    Get From Dictionary    ${items[0].deliveryDate}   startDate
  #${delivery_start_date}=    publicbid_service.convert_item_date_to_string    ${delivery_start_date}
  #${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
  #${delivery_end_date}=      publicbid_service.convert_item_date_to_string  ${delivery_end_date}
  #${item_delivery_region}=      Get From Dictionary    ${items[0].deliveryAddress}    region
  #${item_delivery_region}=     publicbid_service.get_delivery_region    ${item_delivery_region}
  #${item_locality}=  Get From Dictionary  ${items[0].deliveryAddress}  locality
  #${item_delivery_address_street_address}=  Get From Dictionary  ${items[0].deliveryAddress}  streetAddress
  #${item_delivery_postal_code}=  Get From Dictionary  ${items[0].deliveryAddress}  postalCode
  #${latitude}=  Get From Dictionary  ${items[0].deliveryLocation}  latitude
  #${latitude}=  publicbid_service.convert_coordinates_to_string    ${latitude}
  #${longitude}=  Get From Dictionary  ${items[0].deliveryLocation}    longitude
  #${longitude}=  publicbid_service.convert_coordinates_to_string    ${longitude}
  ${cpv_id}=           Get From Dictionary   ${items[0].classification}         id
  ${cpv_id_1}=           Get Substring    ${cpv_id}   0   3
  ${dkpp_id}=        Convert To String     000
  #${code}=           Get From Dictionary   ${items[0].unit}          code
  #${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name
  Selenium2Library.Switch Browser     ${username}
  Wait Until Element Is Visible       xpath=//a[text()='Закупівлі']   10
  Click Element                       xpath=//a[text()='Закупівлі']
  Wait Until Page Contains Element    xpath=//*[text()='НОВА ЗАКУПІВЛЯ']   10
  Click Element                       xpath=//*[text()='НОВА ЗАКУПІВЛЯ']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:procurementType_label']  10
  Click Element                       xpath=//*[@id='mForm:procurementType_label']
  Sleep  2
  ${procurement_type_xpath}=          get_xpath.get_procurement_type_xpath    ${mode}
  Click Element                       xpath=${procurement_type_xpath}
  Sleep  2
  Click Element                       xpath=//*[@id="mForm:chooseProcurementTypeBtn"]
  Wait Until Page Contains Element    id=mForm:name  10
  Input text                          id=mForm:name     ${title}
  Input text                          id=mForm:desc     ${description}
  Run Keyword If    "below" in "${prepared_tender_data.procurementMethodType}"     subkeywords.Додати дати до belowThreshold    ${prepared_tender_data}
  Input text                          id=mForm:dEPr_input    ${tender_period_end_date}
  Click Element                       id=mForm:cKind_label
  Click Element                       xpath=//div[@id='mForm:cKind_panel']//li[3]
  Input text                          id=mForm:cCpvGrL_input      ${cpv_id_1}
  Wait Until Element Is Visible       xpath=//*[@id='mForm:cCpvGrL_panel']/table/tbody/tr/td[2]/span    90
  Click Element                       xpath=//*[@id='mForm:cCpvGrL_panel']/table/tbody/tr/td[2]/span
  #Input text                          id=mForm:bidItem_0:cCpv_input   ${cpv_id}
  #Wait Until Element Is Visible       xpath=//div[@id='mForm:bidItem_0:cCpv_panel']//td[1]/span   90
  #Click Element                       xpath=//div[@id='mForm:bidItem_0:cCpv_panel']//td[1]/span
  Input text                          id=mForm:cDkppGr_input    ${dkpp_id}
  Wait Until Element Is Visible       xpath=//*[@id='mForm:cDkppGr_panel']//tr[1]/td[2]/span    90
  Click Element                       xpath=//*[@id='mForm:cDkppGr_panel']//tr[1]/td[2]/span

  subkeywords.Додати лоти    ${lots}
  subkeywords.Додати предмети    ${items}
  ${meat}=    Evaluate  ${tender_meat} + ${lot_meat} + ${item_meat}
  Run Keyword If    ${meat} > 0    subkeywords.Додати нецінові показники    ${prepared_tender_data}

#  Sleep  2
#  Input text                          id=mForm:bidItem_0:subject    ${item_description}
#  Sleep  2
#  Input text                          id=mForm:bidItem_0:unit_input    ${code}
#  Wait Until Element Is Visible       xpath=//div[@id='mForm:bidItem_0:unit_panel']//tr/td[1]   90
#  Click Element                       xpath=//div[@id='mForm:bidItem_0:unit_panel']//tr/td[1]
#  Input text                          id=mForm:bidItem_0:amount   ${quantity}
#  Input Text                          xpath=//*[@id='mForm:bidItem_0:delDS_input']  ${delivery_start_date}
#  Input text                          xpath=//*[@id="mForm:bidItem_0:delDE_input"]  ${delivery_end_date}
#  Click Element                       xpath=//*[@id="mForm:bidItem_0:cReg"]/div[3]
#  Sleep  1
#  Click Element                       xpath=//ul[@id='mForm:bidItem_0:cReg_items']/li[text()='${item_delivery_region}']
#  Sleep  1
#  Input Text                          xpath=//*[@id="mForm:bidItem_0:cTer_input"]    ${item_locality}
#  Wait Until Element Is Visible       xpath=//*[@id='mForm:bidItem_0:cTer']//td[1]    60
#  Press Key                           //*[@id="mForm:bidItem_0:cTer_input"]    \\13
#  Input text                          id=mForm:bidItem_0:zc  ${item_delivery_postal_code}
#  Input text                          xpath=//*[@id="mForm:bidItem_0:delAdr"]  ${item_delivery_address_street_address}
#  Input text                          id=mForm:bidItem_0:delLoc1  ${latitude}
#  Input text                          id=mForm:bidItem_0:delLoc2  ${longitude}


  Input text                          id=mForm:rName     ${name}
  Input text                          id=mForm:rPhone    ${telephone}
  Input text                          id=mForm:rMail     ${mail}
  Sleep  2
  #Run Keyword if   '${mode}' == 'multi'   Додати предмет   items
  # Save
  Click Element                       id=mForm:bSave
  Wait Until Element Is Visible       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()='Так']    60
  Click Element                       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()='Так']
  # Announce
  Execute JavaScript                  window.scrollTo(0, 0)
  Wait Until Element Is Visible       xpath=//span[text()="Оголосити"]    60
  Sleep  8
  Click Element                       xpath=//span[text()="Оголосити"]
  Sleep   8
  # Confirm in message box
  Click Element                       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Оголосити"]
  Wait Until Element Is Visible       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]    90
  Click Element                       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  # More smart wait for id is needed there.

  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  :FOR    ${INDEX}    IN RANGE    1    25
  \  Exit For Loop If  '${bid_status}' != 'Оголошується'
  \  Sleep  3
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  \  Run Keyword If  '${bid_status}' == 'Оголошується'  Sleep  15
  \  Run Keyword If  '${bid_status}' == 'Оголошується'  Reload Page

  ${tender_UAid}=  Get Text           id=mForm:nBid
  ${tender_UAid}=  Get Substring  ${tender_UAid}  19
  ${Ids}       Convert To String  ${tender_UAid}
  Run keyword if   '${mode}' == 'multi'   Set Multi Ids   ${tender_UAid}
  [return]  ${Ids}


Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  ...      ${ARGUMENTS[2]} ==  id
  Switch browser   ${ARGUMENTS[0]}
  ${current_location}=   Get Location
  Wait Until Element Is Visible    xpath=//a[./text()="Закупівлі"]    60
  Click Element                    xpath=//a[./text()="Закупівлі"]
  Wait Until Element Is Visible    xpath=//div[@id='buttons']/button[1]    30
  Click Element                    xpath=//div[@id='buttons']/button[1]
  Sleep  1
  Input Text                       xpath=//*[@id='search-by-number']/input    ${ARGUMENTS[1]}
  Click Element                    id=mForm:search_button
  Sleep  5
  :FOR    ${INDEX}    IN RANGE    1    45
  \  ${find}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//a[text()='${ARGUMENTS[1]}']/ancestor::div[1]/span[2]/a
  \  Exit For Loop If  '${find}' == 'True'
  \  Sleep  10
  \  Click Element         id=mForm:search_button
  \  Sleep  15
  Click Element    xpath=//a[text()='${ARGUMENTS[1]}']/ancestor::div[1]/span[2]/a
  Wait Until Page Contains    ${ARGUMENTS[1]}   10
  Sleep  5
  Capture Page Screenshot


Оновити сторінку з тендером
  [Arguments]  ${username}  ${tender_uaid}
  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору    ${username}   ${tender_uaid}
  Reload Page


Отримати інформацію із тендера
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}
  Selenium2Library.Switch browser   ${username}
  Run Keyword And Return  view.Отримати інформацію про ${fieldname}


Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If  '${fieldname}' == 'tenderPeriod.endDate'  subkeywords.Змінити дату  ${fieldvalue}
  Run Keyword If  '${fieldname}' == 'description'  subkeywords.Змінити опис  ${fieldvalue}
  Sleep  2
  Click Element              xpath=//*[@id="mForm:bSave"]
  Sleep  5
  Capture Page Screenshot


Завантажити документ
  [Arguments]   ${username}  ${file}  ${tender_uaid}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Choose File       xpath=//*[@id='mForm:docFile_input']    ${file}
  Wait Until Element Is Visible    xpath=//*[text()='Картка документу']    30
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_label"]
  Wait Until Element Is Visible    xpath=//*[@id="mForm:docCard:dcType_panel"]    30
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Sleep  2
  Click Element                    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  10
  Input text                       id=mForm:docAdjust     Test text
  Sleep  5
  Click Element                    xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]    120
  Click Element                    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
  Sleep  120


Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${id}=           Get Text           id=mForm:nBid
  ${Ids}   Create List    ${tender_UAid}   ${id}


Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
  Switch browser   ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${field_xpath}=  get_xpath.get_document_xpath  ${field}  ${doc_id}
  Run Keyword If    '${TEST_NAME}' == 'Відображення заголовку документації до тендера'    Wait Until Keyword Succeeds  300 s  10 s    subkeywords.Wait For Document    ${field_xpath}
  ${value}=    Get Text    ${field_xpath}
  [return]  ${value}


Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${url_doc}=    Get Element Attribute    xpath=//*[contains(text(), '${doc_id}')]@href
  ${file_name}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  ${file_name}=    Convert To String    ${file_name}
  publicbid_service.download_file    ${url_doc}    ${file_name}    ${OUTPUT_DIR}
  [return]  ${file_name}


#                                    ITEM OPERATIONS                                       #

Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  ${index}=    Set Variable If    "${TEST_NAME}" == "Можливість створення лоту із прив’язаним предметом закупівлі"    1
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:subject']    ${item.description}
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cCpv_input']    ${item.classification.id}
  Wait Until Element Is Visible    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cCpv_panel']//td[1]    90
  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cCpv_panel']//td[1]
  ${dkpp_id}=                      Convert To String     000
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cDkpp_input']    ${dkpp_id}
  Wait Until Element Is Visible    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cDkpp_panel']//td[1]    90
  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cDkpp_panel']//td[1]
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:unit_input']    ${item.unit.code}
  Wait Until Element Is Visible    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:unit_panel']//td[1]    90
  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:unit_panel']//td[1]
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:amount']    ${item.quantity}
  ${delivery_start_date}=          Get From Dictionary    ${item.deliveryDate}    startDate
  ${delivery_start_date}=          publicbid_service.convert_item_date_to_string    ${delivery_start_date}
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delDS_input']    ${delivery_start_date}
  ${delivery_end_date}=            Get From Dictionary    ${item.deliveryDate}    endDate
  ${delivery_end_date}=            publicbid_service.convert_item_date_to_string  ${delivery_end_date}
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delDE_input']    ${delivery_end_date}
  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cReg_label']
  ${item_delivery_region}=         Get From Dictionary    ${item.deliveryAddress}    region
  ${item_delivery_region}=         publicbid_service.get_delivery_region    ${item_delivery_region}
  Click Element                    xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cReg_items']/li[text()='${item_delivery_region}']
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cTer_input']    ${item.deliveryAddress.locality}
  Wait Until Element Is Visible    xpath=(//*[@id='mForm:lotItems${index}:lotItem_0:cTer_panel']//td[1])[1]    60
  Press Key                        xpath=//*[@id='mForm:lotItems${index}:lotItem_0:cTer_input']    \\13
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:zc']    ${item.deliveryAddress.postalCode}
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delAdr']    ${item.deliveryAddress.streetAddress}
  ${latitude}=                     Get From Dictionary    ${item.deliveryLocation}    latitude
  ${latitude}=                     publicbid_service.convert_coordinates_to_string    ${latitude}
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delLoc1']    ${latitude}
  ${longitude}=                    Get From Dictionary    ${item.deliveryLocation}    longitude
  ${longitude}=                    publicbid_service.convert_coordinates_to_string    ${longitude}
  Input Text                       xpath=//*[@id='mForm:lotItems${index}:lotItem_0:delLoc2']    ${longitude}


Отримати інформацію із предмету
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${field_name}
  Switch browser    ${username}
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису номенклатури у новому лоті'    subkeywords.Switch new lot    ${username}  ${tender_uaid}
  Run Keyword If    '${TEST_NAME}' == 'Відображення опису нової номенклатури'    Run Keywords
  ...    publicbid.Пошук тендера по ідентифікатору    ${username}  ${tender_uaid}
  ...    AND    Wait Until Keyword Succeeds  300 s  30s  subkeywords.Wait For NewItem    ${item_id}
  ${value}=    subkeywords.Отримати дані з поля item    ${field_name}  ${item_id}
  ${value}=    subkeywords.Адаптувати дані з поля item    ${field_name}  ${value}
  [return]    ${value}


Видалити предмет закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  item_id
  ...      ${ARGUMENTS[3]} ==  lot_id

  Fail    "Драйвер не реалізовано"
  Switch browser    ${ARGUMENTS[0]}


#                                    LOT OPERATIONS                                         #

Створити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити лот із предметом закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${lot}  ${item}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Execute JavaScript                  window.scrollTo(0, 800)
  Click Element    xpath=//*[text()='+']
  ${amount}=    publicbid_service.convert_float_to_string    ${lot.value.amount}
  ${step}=    publicbid_service.convert_float_to_string    ${lot.minimalStep.amount}
  Input Text    id=mForm:lotTitle1    ${lot.title}
  Sleep  1
  Input Text    id=@id=mForm:lotDesc1    ${lot.description}
  Sleep  1
  Input Text    id=mForm:lotBudg1    ${amount}
  Sleep  30
  Input Text    id=mForm:lotStep1    ${step}
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:lotVat1']//span)[1]
  publicbid.Додати предмет закупівлі    ${username}  ${tender_uaid}  ${item}
  Click Element    id=mForm:bSave
  Wait Until Element Is Visible    xpath=//*[text()='Збережено!']    120


Отримати інформацію із лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${field_name}
  Switch browser    ${username}
  ${status}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[contains(@value, '${lot_id}')]
  Run Keyword if    '${status}' == 'False'    Click Element    xpath=//button[contains(text(), '${lot_id}')]
  Sleep  1
  ${value}=    subkeywords.Отримати дані з поля lot    ${field_name}  ${lot_id}  ${mode}
  ${value}=    subkeywords.Адаптувати дані з поля lot    ${field_name}  ${value}
  [return]    ${value}


Змінити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${fieldname}  ${fieldvalue}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Clear Element Text    xpath=//*[contains(text(), '${lot_id}')]//ancestor::div[@id='mForm:lots']/div[2]/table//tr[7]/td[2]/input
  ${value}=    publicbid_service.convert_float_to_string    ${fieldvalue}
  Input Text    xpath=//*[contains(text(), '${lot_id}')]//ancestor::div[@id='mForm:lots']/div[2]/table//tr[7]/td[2]/input    ${value}
  Sleep  2
  Input Text    id=mForm:lotStepPercent0    1
  Click Element    id=mForm:bSave
  Wait Until Element Is Visible    xpath=//*[text()='Збережено!']    120

Додати предмет закупівлі в лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${item}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Execute JavaScript                  window.scrollTo(0, 800)
  Click Element    xpath=//*[contains(text(), '${lot_id}')]
  //*[contains(@value, '${lot_id}')]//ancestor::div[@class='ui-outputpanel ui-widget lotTab active']//*[text()='Додати предмет до лоту']
  publicbid.Додати предмет закупівлі    ${username}  ${tender_uaid}  ${item}


Завантажити документ в лот
  [Arguments]  ${username}  ${filepath}  ${tender_uaid}  ${lot_id}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Choose File    xpath=//*[@id='mForm:docFile_input']    ${filepath}
  Wait Until Element Is Visible    xpath=//*[text()='Картка документу']    30
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_label"]
  Wait Until Element Is Visible    xpath=//*[@id="mForm:docCard:dcType_panel"]    30
  Click Element                    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Sleep  2
  Click Element                    xpath=(//*[text()='Картка закупівлі'])[2]
  Click Element                    xpath=(//*[contains(@data-label, '${lot_id}')])[1]
  Click Element                    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  10
  Clear Element Text               id=mForm:docAdjust
  Input text                       id=mForm:docAdjust     Dok text
  Sleep  5
  Click Element                    xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]    120
  Click Element                    xpath=(//*[@id="primefacesmessagedlg"]/div/a)[1]
  Sleep  120

Видалити лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Скасувати лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${cancellation_reason}  ${document}  ${description}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Отримати інформацію з документа до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}  ${field}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Отримати документ до лоту
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${doc_id}
  ${file_name}=    publicbid.Отримати документ    ${username}  ${tender_uaid}  ${doc_id}
  [return]  ${file_name}


#                                    FEATURES OPERATIONS                                    #

Додати неціновий показник на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${feature}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Додати неціновий показник на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${item_id}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Додати неціновий показник на лот
  [Arguments]  ${username}  ${tender_uaid}  ${feature}  ${lot_id}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Отримати інформацію із нецінового показника
  [Arguments]  ${username}  ${tender_uaid}  ${feature_id}  ${field_name}
  Switch browser    ${username}
  Run Keyword If    'Відображення заголовку нецінового показника' in '${TEST_NAME}'    Run Keywords
  ...    publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ...    AND    Wait Until Keyword Succeeds  360 s  10 s  subkeywords.Wait For NewFeature  ${feature_id}
  Sleep  3
  ${value}=    subkeywords.Отримати дані з поля feature    ${field_name}  ${feature_id}
  ${value}=  Run Keyword If  '${field_name}' == 'featureOf'    publicbid_service.convert_data_feature  ${value}
  ...        ELSE    Set Variable    ${value}
  [return]  ${value}


Видалити неціновий показник
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  feature_id

  Fail    "Драйвер не реалізовано"
  Switch browser    ${ARGUMENTS[0]}


#                                    QUESTION                                               #

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Wait Until Element Is Visible       xpath=//span[./text()='Обговорення']    30
  Click Element                       xpath=//span[./text()='Обговорення']
  Input Text                          xpath=//*[@id="mForm:messT"]  ${title}
  Input Text                          xpath=//*[@id="mForm:messQ"]  ${description}
  Sleep  5
  Click Element                       xpath=//*[@id="mForm:btnQ"]
  Sleep  30

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Wait Until Element Is Visible       xpath=//span[./text()='Обговорення']    30
  Click Element                       xpath=//span[./text()='Обговорення']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:questTo_label']    30
  Click Element                       xpath=//*[@id='mForm:questTo_label']
  Sleep  1
  Click Element                       xpath=(//*[contains(text(), 'Предмет закупівлі')])[2]
  Input Text                          xpath=//*[@id='mForm:messT']    ${title}
  Input Text                          xpath=//*[@id='mForm:messQ']    ${description}
  Sleep  5
  Click Element                       xpath=//*[@id='mForm:btnQ']
  Sleep  30


Задати запитання на лот
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}  ${question}

  ${title}=         Get From Dictionary   ${question.data}   title
  ${description}=   Get From Dictionary   ${question.data}   description

  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Wait Until Element Is Visible        xpath=//span[./text()='Обговорення']   30
  Click Element                        xpath=//span[./text()='Обговорення']
  Wait Until Element Is Visible       xpath=//*[@id='mForm:questTo_label']    30
  Click Element                       xpath=//*[@id='mForm:questTo_label']
  Sleep  1
  Click Element                       xpath=(//*[@id='mForm:questTo_panel']//*[contains(text(), '${lot_id}')])[1]
  Input Text                          xpath=//*[@id='mForm:messT']    ${title}
  Input Text                          xpath=//*[@id='mForm:messQ']    ${description}
  Sleep  5
  Click Element                       xpath=//*[@id='mForm:btnQ']
  Sleep  30

Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
  Selenium2Library.Switch browser   ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element      xpath=//span[text()='Обговорення']
  ${field_xpath}=    get_xpath.get_question_xpath    ${field_name}    ${question_id}
  Wait Until Keyword Succeeds    300 s    10 s    subkeywords.Wait For Question    ${field_xpath}
  ${value}=    Get Text    xpath=${field_xpath}
  [return]  ${value}

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  ${answer}=     Get From Dictionary    ${answer_data.data}    answer
  Selenium2Library.Switch Browser    ${username}
  Sleep  5
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Element Is Visible    xpath=//*[@id="mForm:status"]   60
  ${tender_status}=    Get Text    xpath=//*[@id="mForm:status"]
  Run Keyword If  '${tender_status}' != 'Період уточнень'    Fail    "Період уточнень закінчився"
  Click Element                      xpath=//span[./text()='Обговорення']
  Sleep  3
  Click Element                      xpath=//span[contains(text(), '${question_id}')]/ancestor::div[@id='mForm:data_content']//button
  Input Text    xpath=//*[@id="mForm:messT"]    "Test answer"
  Input Text    xpath=//*[@id="mForm:messQ"]    ${answer}
  Sleep  2
  Click Element                      xpath=//*[@id="mForm:btnR"]
  Sleep  30

#                                CLAIMS                                 #

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Sleep  1
  Click Element    xpath=//span[text()='Нова вимога']
  Wait Until Element Is Visible    //span[text()='Обрати']    30
  Click Element    xpath=//span[text()='Обрати']
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  1
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  1
  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  30


Створити чернетку про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Створити вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${document}=${None}
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Sleep  1
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  5
  Run Keyword If    '${TEST_NAME}' != 'Можливість створити і подати вимогу про виправлення умов лоту'    Click Element    xpath=//span[text()='Обрати']
  Sleep  2
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  1
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  1
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//*[text()='Завантажити документ']//ancestor::div[1]//input    ${document}

  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  30
  ${type}=  Set Variable If    'закупівлі' in '${TEST_NAME}'    tender
  ...                          'лоту' in '${TEST_NAME}'    lot
  ${complaintID}=    publicbid_service.convert_complaintID    ${tender_uaid}    ${type}
  Sleep  90
  [return]  ${complaintID}


Створити вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${lot_id}  ${document}=${None}
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Sleep  1
  Click Element    xpath=//span[text()='Нова вимога']
  Sleep  5
  Input Text    xpath=//*[@id='mForm:data:title']    ${claim.data.title}
  Sleep  1
  Input Text    xpath=//*[@id='mForm:data:description']    ${claim.data.description}
  Sleep  1
  Run Keyword If    '${document}' != '${None}'    Choose File    xpath=//*[text()='Завантажити документ']//ancestor::div[1]//input    ${document}

  Click Element    xpath=//span[text()='Зареєструвати']
  Sleep  30
  ${type}=  Set Variable If    'закупівлі' in '${TEST_NAME}'    tender
  ...                          'лоту' in '${TEST_NAME}'    lot
  ${complaintID}=    publicbid_service.convert_complaintID    ${tender_uaid}    ${type}
  Sleep  90
  [return]  ${complaintID}


Створити вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  claim
  ...      ${ARGUMENTS[3]} ==  award_index
  ...      ${ARGUMENTS[4]} ==  document

  Fail    "Драйвер не реалізовано"
  Switch browser    ${ARGUMENTS[0]}


Завантажити документацію до вимоги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${document}
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//span[text()='Вимоги та скарги']
  Wait Until Element Is Visible    xpath=//*[text()='${complaintID}']    30
  Click Element    //*[text()='${complaintID}']


Завантажити документацію до вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${award_index}  ${document}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Подати вимогу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Подати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${award_index}  ${confirmation_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Відповісти на вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser    ${username}


Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  Click Element    xpath=//*[text()='Погодитись з відповіддю']
  Sleep  15


Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Run Keyword If    '${TEST_NAME}' == 'Можливість підтвердити задоволення вимоги про виправлення умов лоту'    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Answered
  Sleep  2
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  2
  Click Element    xpath=//*[text()='Погодитись з відповіддю']
  Sleep  15


Підтвердження вирішення вимоги про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  publicbid.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Click Element    xpath=//span[text()='Вимоги та скарги']
  Wait Until Element Is Visible    xpath=//*[text()='${complaintID}']    30
  Click Element    //*[text()='${complaintID}']
  Input Text    xpath=//*[@id='mForm:data:cancellationReason']    ${cancellation_data.data.cancellationReason}
  Click Element    xpath=//*[text()='Відмінити вимогу/скаргу']


Скасувати вимогу про виправлення умов лоту
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасувати вимогу про виправлення визначення переможця
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Перетворити вимогу про виправлення умов закупівлі в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Перетворити вимогу про виправлення умов лоту в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Перетворити вимогу про виправлення визначення переможця в скаргу
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${escalating_data}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати інформацію із скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${field_name}  ${award_index}=${None}
  Selenium2Library.Switch browser   ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов закупівлі"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimTender
  Run Keyword If    "${TEST_NAME}" == "Відображення опису вимоги про виправлення умов лоту"    Wait Until Keyword Succeeds  300 s  10 s  subkeywords.Wait For ClaimLot
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  Run Keyword If    "Можливість відповісти на вимогу" in "${TEST_NAME}"    Wait Until Keyword Succeeds  360 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "Відображення статусу 'answered' вимоги" in "${TEST_NAME}"    Wait Until Keyword Succeeds  360 s  15 s  subkeywords.Wait For Answered
  Run Keyword If    "${TEST_NAME}" == "Відображення задоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "${TEST_NAME}" == "Відображення незадоволення вимоги"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "Відображення статусу 'resolved'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Satisfied
  Run Keyword If    "Відображення статусу 'cancelled'" in "${TEST_NAME}"    Wait Until Keyword Succeeds  300 s  15 s  subkeywords.Wait For Cancelled
  ${field_xpath}=    get_xpath.get_claims_xpath    ${field_name}
  ${type_field}=    publicbid_service.get_type_field    ${field_name}
  ${value}=  Run Keyword If    '${type_field}' == 'value'    Get Value    ${field_xpath}
  ...     ELSE IF             '${type_field}' == 'text'    Get Text    ${field_xpath}
  ${return_value}=  Run Keyword If    '${field_name}' == 'status'    publicbid_service.get_claim_status    ${value}    "${TEST_NAME}"
  ...    ELSE IF                      '${field_name}' == 'resolutionType'    publicbid_service.get_resolution_type    ${value}
  ...    ELSE IF                      '${field_name}' == 'satisfied'    publicbid_service.convert_satisfied    ${value}
  ...    ELSE IF                      '${field_name}' == 'complaintID'    Set Variable    ${complaintID}
  ...    ELSE    Set Variable    ${value}
  [return]  ${return_value}


Отримати інформацію із документа до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${field_name}  ${award_id}=${None}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:data_data']/tr/td[1]/a    30
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  ${value}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  [return]  ${value}


Отримати документ до скарги
  [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${award_id}=${None}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Run Keyword If    '${mode}' != 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та скарги']
  Run Keyword If    '${mode}' == 'belowThreshold'    Click Element    xpath=//*[text()='Вимоги та звернення']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:data_data']/tr/td[1]/a    30
  Click Element    xpath=(//*[@id='mForm:data_data']/tr/td[1]/a)[1]
  Sleep  3
  ${url_doc}=    Get Element Attribute    xpath=//*[contains(text(), '${doc_id}')]@href
  ${file_name}=    Get Text    xpath=//*[contains(text(), '${doc_id}')]
  ${file_name}=    Convert To String    ${file_name}
  publicbid_service.download_file    ${url_doc}    ${file_name}    ${OUTPUT_DIR}
  [return]  ${file_name}

#                               BID OPERATIONS                          #

Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=${None}  ${features_ids}=${None}
  Switch browser  ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:status"]
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Fail  "Неможливо подати цінову пропозицію в період уточнень"
  Click Element    xpath=//span[text()='Подати пропозицію']

  Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Подати цінову пропозицію для below    ${bid}
  Run Keyword If    '${mode}' == 'openua'    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}
  Run Keyword If    '${mode}' == 'openeu'    subkeywords.Подати цінову пропозицію для open    ${bid}    ${lots_ids}    ${features_ids}

  Input Text  xpath=//*[@id="mForm:data:rName"]    Тестовий закупівельник
  Input Text  xpath=//*[@id="mForm:data:rPhone"]    ${telephone}
  Input Text  xpath=//*[@id="mForm:data:rMail"]    ${mail}

  Click Element  xpath=//*[text()='Зберегти']
  Sleep  3
  Wait Until Element Is Visible    xpath=//*[@id='mForm:proposalSaveInfo']/div[3]/button    60
  Click Element  xpath=//*[@id='mForm:proposalSaveInfo']/div[3]/button/span[2]
  Sleep  1
  Wait Until Element Is Visible    xpath=//*[text()='Зареєструвати пропозицію']    60
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  Wait Until Element Is Visible    xpath=//*[@id='mForm:cdPay']    60
  Click Element    xpath=//*[@id='mForm:cdPay']/div[2]/table//tr[6]/td//tr[2]/td/div
  Sleep  1
  Click Element    xpath=(//li[contains(text(), "prozz1@yopmail.com")])[2]
  Sleep  1
  Click Element  xpath=(//*[text()='Зареєструвати пропозицію'])[2]
  Wait Until Element Is Visible    //*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]    90
  ${bid_status}=    Get Text    xpath=//*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]
  :FOR    ${INDEX}    IN RANGE    1    25
  \  Exit For Loop If  '${bid_status}' == 'Зареєстрована'
  \  Sleep  3
  \  ${bid_status}=  Get Text  xpath=//*[@id='mForm:data']/div[1]/table/tbody/tr[5]/td[2]
  \  Run Keyword If  '${bid_status}' == 'Реєструється'  Sleep  15
  \  Run Keyword If  '${bid_status}' == 'Реєструється'  Reload Page
  Sleep  30


Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  publicbid.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Змінити цінову пропозицію below    ${fieldvalue}
  ...    ELSE IF    '${mode}' != 'belowThreshold'    subkeywords.Змінити цінову пропозицію open    ${fieldname}    ${fieldvalue}


Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  publicbid.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Click Element    xpath=//*[@id='mForm:proposalDeleteBtn']
  Click Element    xpath=//*[text='Видалити']
  Sleep  5


Завантажити документ в ставку
  [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=documents
  publicbid.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Choose File       xpath=//*[@id='mForm:data:tFile_input']    ${path}
  Wait Until Element Is Visible    xpath=//*[@id='mForm:docCard:dcType_label']    60
  Click Element    xpath=//*[@id='mForm:docCard:dcType_label']
  Sleep  2
  Click Element    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Sleep  2
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  10
  Click Element    xpath=//*[text()='Зберегти']
  Sleep  15


Змінити документ в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${path}  ${doc_id}
  publicbid.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Execute JavaScript                  window.scrollTo(0, 1000)
  Sleep  2
  Click Element    xpath=//a[contains(text(), '${doc_id}')]//ancestor::tr/td[6]/button[1]/span[1]
  Wait Until Element Is Visible    xpath=//*[text()= 'Картка документу']
  Choose File       xpath=//*[@id='mForm:docCard:dcFile_input']    ${path}
  Sleep  5
  Click Element    xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  10
  Click Element    xpath=//*[text()='Зберегти']
  Sleep  15


Змінити документацію в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${doc_id}
  publicbid.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Execute JavaScript                  window.scrollTo(0, 800)
  Sleep  2
  Click Element    xpath=//a[contains(text(), '${doc_id}')]//ancestor::tr/td[6]/button[1]/span[1]
  Wait Until Element Is Visible    xpath=//*[text()= 'Картка документу']    30
  Click Element    xpath=//*[@id='mForm:docCard:dcType_label']
  Sleep  2
  Click Element    xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[3]
  Sleep  2
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  10
  Click Element    xpath=//*[text()='Зберегти']
  Sleep  15


Отримати інформацію із пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${field}
  publicbid.Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Run Keyword If    "${TEST_NAME}" == "Відображення зміни статусу першої пропозиції після редагування інформації про тендер"    Wait Until Keyword Succeeds  420 s  15 s  subkeywords.Wait For Status
  ${return_value}=    Run Keyword If    '${mode}' == 'belowThreshold'    subkeywords.Отримати дані з bid below
  ...    ELSE IF                      '${mode}' != 'belowThreshold'    subkeywords.Отримати дані з bid open    ${field}
  [return]  ${return_value}


Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]    30
  Sleep  2
  ${auction_url}=    Get Element Attribute    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]@onclick
  ${url}=    Get Substring    ${auction_url}    80    -11
  [return]  ${url}


Пошук цінової пропозиції
  [Arguments]  ${username}  ${tender_uaid}
  Switch browser   ${username}
  Click Element  xpath=//*[text()='Особистий кабiнет']
  Wait Until Element Is Visible    xpath=//*[@id='wrapper']/div[1]/span/b    30
  Click Element    xpath=//*[@id='wrapper']/div[1]/span/b
  Wait Until Element Is Visible    xpath=//*[@id='wrapper']//li[5]    30
  Sleep  3
  Click Element At Coordinates    xpath=//*[@id='wrapper']//li[5]/a    -15    0
  Wait Until Element Is Visible    xpath=//*[contains(text(), '${tender_uaid}')]//ancestor::tbody/tr[1]/td[1]/div    30
  Click Element    xpath=//*[contains(text(), '${tender_uaid}')]//ancestor::tbody/tr[1]/td[1]/div
  Wait Until Element Is Visible    xpath=//span[text()='Відкрити детальну інформацію']    30
  Click Element    xpath=//span[text()='Відкрити детальну інформацію']
  Sleep  10


Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
  Sleep  130
  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]    30
  Sleep  2
  ${auction_url}=    Get Element Attribute    xpath=//*[contains(@onclick, 'https://auction-sandbox.openprocurement.org/tenders/')]@onclick
  ${url}=    Get Substring    ${auction_url}    80    -11
  [return]  ${url}


#                      QUALIFICATION OPERATIONS                     #

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


#                       LIMITED PROCUREMENT                          #

Створити постачальника, додати документацію і підтвердити його
  [Arguments]  ${username}  ${tender_uaid}  ${supplier_data}  ${document}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасувати закупівлю
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Завантажити документацію до запиту на скасування
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${document}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Змінити опис документа в скасуванні
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_id}  ${document_id}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Підтвердити скасування закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${cancell_id}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати інформацію із документа до скасування
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_id}  ${doc_id}  ${field_name}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати документ до скасування
  [Arguments]  ${username}  ${cancellation_id}  ${tender_uaid}  ${doc_id}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


#                               OPEN PROCUREMENT                                #

Підтвердити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Відхилити кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Завантажити документ у кваліфікацію
  [Arguments]  ${username}  ${document}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Скасувати кваліфікацію
  [Arguments]  ${username}  ${tender_uaid}  ${qualification_num}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Затвердити остаточне рішення кваліфікації
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Перевести тендер на статус очікування обробки мостом
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Отримати доступ до тендера другого етапу
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


Активувати другий етапу
  [Arguments]  ${username}  ${tender_uaid}
  Fail    "Драйвер не реалізовано"
  Switch browser  ${username}


