*** Settings ***
Documentation  add abstract in excel file
Library  SeleniumLibrary
Library  AddToCSV.py
Test Template  Extract Abstracts
*** Variables ***
${BROWSER}  headlesschrome
${ArticleUrl}  https://link.springer.com/search?facet-language=%22En%22&showAll=true&date-facet-mode=between&query=%22useful+work%22+AND+%28consensus+OR++OR+blockchain+OR++OR+proof%29&facet-discipline=%22Computer+Science%22&facet-content-type=%22Article%22
${ConferanceUrl}  https://link.springer.com/search?facet-language=%22En%22&facet-content-type=%22ConferencePaper%22&showAll=true&facet-discipline=%22Computer+Science%22&date-facet-mode=between&query=%22useful+work%22+AND+%28consensus+OR++OR+blockchain+OR++OR+proof%29
${title}  (//a[@class="title"])
${header}  //*[@id="main"]/header/div/div/div[1]/h1
${abstract1}  //*[@id="Abs1-content"]/p
${abstract2}  //*[@id="Ab1-content"]/p
${ArtileFile}  Article.csv
${ConferenceFile}  Conference.csv
${NumOfPages}   //*[@id="kb-nav--main"]/div[4]/form/span[2]/span[2]
${nextBTN}  //*[@id="kb-nav--main"]/div[4]/form/a/img

*** Test Cases ***                        url               file  
Extract Article Papers Abstracts      ${ArticleUrl}     ${ArtileFile} 
#Extract Conference Papers Abstracts   ${ConferanceUrl}  ${ConferenceFile}

*** Keywords ***
Extract Abstracts
    [Arguments]   ${Url}  ${File} 
    Set Selenium Timeout	40 seconds
    Open Browser  browser=${BROWSER}   options=add_experimental_option("detach",True)
    Go To  ${Url}
    Wait UntiL Element Is Visible  xpath:/html/body/dialog/div[2]/div/div[2]/button
    Click Element  xpath:/html/body/dialog/div[2]/div/div[2]/button
    Wait UntiL Element Is Visible  //*[@id="main"]/div/div[1]/div/div[1]/div/p/a
    Click Element      //*[@id="main"]/div/div[1]/div/div[1]/div/p/a
    Wait UntiL Element Is Visible  ${NumOfPages}
    Go To  ${Url}
    Wait UntiL Element Is Visible  ${NumOfPages}
    ${NumOfPagesTxt}=  Get Text  ${NumOfPages}
    FOR    ${page}    IN RANGE    ${NumOfPagesTxt}
        ${NumOfTitleInPage}=  Get Element Count  ${title}
        FOR    ${index}    IN RANGE   1  ${NumOfTitleInPage}
            ${TitleElement} =   Catenate    SEPARATOR=   ${title}   [${index}]
            Wait UntiL Element Is Visible  ${TitleElement}
            Click Element  ${TitleElement}
            Wait UntiL Element Is Visible  ${header}
            ${FirstType}=  Run Keyword And Return Status  Element Should Be Visible  ${abstract1}
            IF    ${FirstType}
                ${abstractTxt}=  Get Text  ${abstract1}
            ELSE
                ${abstractTxt}=  Get Text  ${abstract2}
            END           
            add_to_csv  ${abstractTxt}  ${index}  ${File} 
            Go Back
        END
        Click Element  ${nextBTN}
    END