<#--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->
<#include "component://shop/webapp/shop/customer/customercommon.ftl">
<#include "component://setup/webapp/setup/common/common.ftl">

<#assign defaultParams = {
    "USER_ADDRESS_ALLOW_SOL": "Y",
    "USER_MOBILE_ALLOW_SOL": "Y",
    "USER_WORK_ALLOW_SOL": "Y",
    "USER_FAX_ALLOW_SOL": "Y",
    "USER_EMAIL_ALLOW_SOL": "Y",
    
    "PRODUCT_STORE_ID": "${productStoreId}"
}>

<#assign paramMaps = getWizardFormFieldValueMaps({
    "record":userInfo!true,   
    "defaults":defaultParams
})>
<#assign params = paramMaps.values>
<#assign fixedParams = paramMaps.fixedValues>

<@script>
    <#if getUsername>    
         lastFocusedName = null;
         function setLastFocused(formElement) {
             lastFocusedName = formElement.name;
             document.write.lastFocusedName;
         }
         function clickUsername() {
             if (document.getElementById('UNUSEEMAIL').checked) {
                 if (lastFocusedName == "UNUSEEMAIL") {
                     jQuery('#PASSWORD').focus();
                 } else if (lastFocusedName == "PASSWORD") {
                     jQuery('#UNUSEEMAIL').focus();
                 } else {
                     jQuery('#PASSWORD').focus();
                 }
             }
         }
         function changeEmail() {
             if (document.getElementById('UNUSEEMAIL').checked) {
                 document.getElementById('USERNAME').value = jQuery('#USER_EMAIL').val();
             }
         }
         function setEmailUsername(noreset) {
             if (document.getElementById('UNUSEEMAIL') != null && document.getElementById('UNUSEEMAIL').checked) {
                 document.getElementById('USERNAME').value = jQuery('#USER_EMAIL').val();
                 <#-- don't disable, make the browser not submit the field: document.getElementById('USERNAME').disabled=true; -->
                 <#-- SCIPIO: ... but DO set disabled class so user sees as if was disabled -->
                 jQuery('#USERNAME').slideUp('slow');
             } else {
                 if (noreset !== true) { <#-- SCIPIO: extra check -->
                    document.getElementById('USERNAME').value='';
                 }
                 <#-- document.getElementById('USERNAME').disabled=false; -->
                 jQuery('#USERNAME').slideDown('slow');
             }
         }   
    </#if>
    jQuery(document).ready(function() {        
        <#-- SCIPIO: do this also on page load -->
        setEmailUsername(true);
    });
</@script>
    
<@alert type="warning">WARNING: WORK-IN-PROGRESS</@alert>

<@form method="post" action=makeOfbizUrl(target) id=submitFormId name=submitFormId validate=setupFormValidate>
    <@defaultWizardFormFields exclude=["userPartyId"] />
    <@field type="hidden" name="isCreateUser" value=(user??)?string("N","Y")/>    
    <@field type="hidden" name="PRODUCT_STORE_ID" value=(fixedParams.PRODUCT_STORE_ID!)/>
    
    
    
    <#if userParty??>
        <@field type="display" name="userPartyId" value=(userParty.partyId!) label=uiLabelMap.PartyPartyId />
    <#else>
        <@field type="input" name="userPartyId" value=(params.userPartyId!) label=uiLabelMap.PartyPartyId placeholder="User"/>
    </#if>	
    	
    <#assign fieldsRequired = true>
    	
    <#if !getUsername?has_content || (getUsername?has_content && getUsername)>    	      
        <#macro extraFieldContent args={}>	          
          <@field type="checkbox" checkboxType="simple-standard" name="UNUSEEMAIL" id="UNUSEEMAIL" value="on" onClick="setEmailUsername();" onFocus="setLastFocused(this);" label=uiLabelMap.SetupUseEmailAddress checked=((parameters.UNUSEEMAIL!) == "on")/>
        </#macro>
        <#assign fieldStyle = "">    	        
        <#if !userUserLogin?has_content>
           <#if ((parameters.UNUSEEMAIL!) == "on")>
              <#assign fieldStyle = "display:none;">
            </#if>
           <@field type="text" name="USERNAME" id="USERNAME" style=fieldStyle value=(params.userLoginId!) onFocus="clickUsername();" onchange="changeEmail();" label=uiLabelMap.CommonUsername required=true postWidgetContent=extraFieldContent />
        <#else>
           <@field type="display" value=(userUserLogin.userLoginId!) label=uiLabelMap.CommonUsername />
           <@field type="hidden" name="USERNAME" value=(params.userLoginId!)/>
        </#if>    	      
    </#if>
    	
    <#if !createAllowPassword?has_content || (createAllowPassword?has_content && createAllowPassword)>    	      
      <@field type="password" name="PASSWORD" id="PASSWORD" onFocus="setLastFocused(this);" label=uiLabelMap.CommonPassword required=(!userUserLogin?has_content)!true />      
      <@field type="password" name="CONFIRM_PASSWORD" id="CONFIRM_PASSWORD" value="" maxlength="50" label=uiLabelMap.PartyRepeatPassword required=(!userUserLogin?has_content)!true />		      
    <#else>
      <@commonMsg type="info-important">${uiLabelMap.PartyReceivePasswordByEmail}.</@commonMsg>
    </#if>
    
    
    <@field type="generic" label=uiLabelMap.PartyRoleType labelDetail=fieldLabelDetail>
        <@fields args={"type":"default-nolabelarea", "ignoreParentField":true}>
            <@field type="select" name="roleTypeId" id="roleTypeId">
                <option value="" selected="selected">--</option>
                <#list userPartyRoles as partyRole>
                    <#assign selected = (userPartyRole?? && rawString(userPartyRole.roleTypeId) == rawString(partyRole.roleTypeId!))>
                    <option value="${partyRole.roleTypeId}"<#if selected> selected="selected"</#if>>${partyRole.description}</option>
                </#list>
            </@field>
            
            <@field type="display" value=getLabel('SetupIsRelatedToOrgAs', '', {"orgPartyId":rawString(orgPartyId!)}) />
            
            <@field type="select" name="partyRelationshipTypeId" id="partyRelationshipTypeId">
                <option value="" selected="selected">--</option>
                <#list userPartyRelationshipTypes as userPartyRelationshipType>
                    <#assign selected = (partyRelationship?? && rawString(partyRelationship.partyRelationshipTypeId) == rawString(userPartyRelationshipType.partyRelationshipTypeId!))>
                    <option value="${userPartyRelationshipType.partyRelationshipTypeId}"<#if selected> selected="selected"</#if>>${userPartyRelationshipType.partyRelationshipName}</option>
                </#list>
            </@field>
        </@fields>
    </@field>
    
	<hr/> 
	 
    <input type="hidden" name="emailProductStoreId" value="${productStoreId}"/>    
    <@personalTitleField name="USER_TITLE" label=uiLabelMap.CommonTitle /> 
    <@field type="input" name="USER_FIRST_NAME" id="USER_FIRST_NAME" value=(params.firstName!) label=uiLabelMap.PartyFirstName required=true />
    <@field type="input" name="USER_LAST_NAME" id="USER_LAST_NAME" value=(params.lastName!) label=uiLabelMap.PartyLastName required=true />
    
    <hr/>
    
    <@field type="generic" label=uiLabelMap.PartyGeneralAddress labelDetail=fieldLabelDetail>
        <div id="setupUser-editMailShipAddr-area">
        	<@fields args={"type":"default", "ignoreParentField":true}>
                <@render resource="component://setup/widget/ProfileScreens.xml#postalAddressFields" 
                      ctxVars={
                        "pafFieldNamePrefix":"USER_",
                        "pafFieldIdPrefix":"EditUser_",
                        "pafUseScripts":true,
                        "pafFallbacks":({}),
                        "pafParams": params,                    
                        "pafFieldNameMap": {
                          "stateProvinceGeoId": "STATE",
                          "countryGeoId": "COUNTRY",
                          "address1": "ADDRESS1",
                          "address2": "ADDRESS2",
                          "city": "CITY",
                          "postalCode": "POSTAL_CODE"
                        },
                        "pafUseToAttnName":false,
                        "pafMarkRequired":fieldsRequired
                      }/>
                <@field type="hidden" name="USER_ADDRESS_ALLOW_SOL" value=(fixedParams.USER_ADDRESS_ALLOW_SOL!)/>        
                <#if userPostalAddress?has_content>
                    <@field type="hidden" name="USER_POSTAL_ADDRESS_CONTACT_MECH_ID" value=(userPostalAddress.contactMechId!)/>
                </#if>
            </@fields>
        </div>
    </@field>
	
	<#if userWorkNumber?has_content>
        <@field type="hidden" name="USER_WORK_CONTACTMECHID" value=(userWorkNumber.contactMechId!)/>
    </#if>
    <@telecomNumberField label=uiLabelMap.PartyContactWorkPhoneNumber params=params
        fieldNamePrefix="USER_WORK_" countryCodeName="COUNTRY" areaCodeName="AREA" contactNumberName="CONTACT" extensionName="EXT">
        <@fields type="default-compact" ignoreParentField=true>                    
        <@field type="hidden" name="USER_WORK_ALLOW_SOL" value=(fixedParams.USER_WORK_ALLOW_SOL!)/>        
    </@fields>
    </@telecomNumberField>
    
    <#if userMobileNumber?has_content>
        <@field type="hidden" name="USER_MOBILE_CONTACTMECHID" value=(userMobileNumber.contactMechId!)/>
    </#if>
    <@telecomNumberField label=uiLabelMap.PartyContactMobileNumber params=params
        fieldNamePrefix="USER_MOBILE_" countryCodeName="COUNTRY" areaCodeName="AREA" contactNumberName="CONTACT" extensionName="EXT">
        <@fields type="default-compact" ignoreParentField=true>                    
            <@field type="hidden" name="USER_MOBILE_ALLOW_SOL" value=(fixedParams.USER_MOBILE_ALLOW_SOL!)/>            
        </@fields>
    </@telecomNumberField>
    
     <#if userFaxNumber?has_content>
        <@field type="hidden" name="USER_FAX_CONTACTMECHID" value=(userFaxNumber.contactMechId!)/>
    </#if>
    <@telecomNumberField label=uiLabelMap.PartyContactFaxPhoneNumber params=params
        fieldNamePrefix="USER_FAX_" countryCodeName="COUNTRY" areaCodeName="AREA" contactNumberName="CONTACT" extensionName="EXT">
        <@fields type="default-compact" ignoreParentField=true>                    
        <@field type="hidden" name="USER_FAX_ALLOW_SOL" value=(fixedParams.USER_FAX_ALLOW_SOL!)/>
       
      </@fields>
    </@telecomNumberField>
    
    <#if params.USER_EMAIL_CONTACTMECHID?has_content>
      <@field type="hidden" name="USER_EMAIL_CONTACTMECHID" value=(params.USER_EMAIL_CONTACTMECHID!)/>
    </#if>
    <@field type="input" name="USER_EMAIL" id="USER_EMAIL" value=(params.USER_EMAIL!) onChange="changeEmail()" onkeyup="changeEmail()" label=uiLabelMap.PartyEmailAddress />            
    <@field type="hidden" name="USER_EMAIL_ALLOW_SOL" value=(fixedParams.USER_EMAIL_ALLOW_SOL!)/>    
</@form>

