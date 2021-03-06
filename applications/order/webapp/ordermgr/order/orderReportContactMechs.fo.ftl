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
<#escape x as x?xml>
<fo:block content-width="85mm" font-size="10pt" margin-top="45mm" margin-bottom="5mm">
    <fo:block-container height="5mm" font-size="6pt">
        <fo:block>
            <#-- Return Address -->
            ${companyName!""}
        </fo:block>
    </fo:block-container>
    <fo:block margin-bottom="2mm">
        <#-- Contact Information -->
        <#if orderHeader.getString("orderTypeId") == "PURCHASE_ORDER">
            <#if supplierGeneralContactMechValueMap??>
                <#assign contactMech = supplierGeneralContactMechValueMap.contactMech>
                <fo:block font-weight="bold">${uiLabelMap.OrderPurchasedFrom}:</fo:block>
                <#assign postalAddress = supplierGeneralContactMechValueMap.postalAddress>
                <#if postalAddress?has_content>
                    <fo:block>
                        <#if postalAddress.toName?has_content><fo:block>${postalAddress.toName}</fo:block></#if>
                        <#if postalAddress.attnName?has_content><fo:block>${postalAddress.attnName!}</fo:block></#if>
                        <fo:block>${postalAddress.address1!}</fo:block>
                        <#if postalAddress.address2?has_content><fo:block>${postalAddress.address2!}</fo:block></#if>
                        <fo:block>
                            <#assign stateGeo = (delegator.findOne("Geo", {"geoId", postalAddress.stateProvinceGeoId!}, false))! />
                            ${postalAddress.city}<#if stateGeo?has_content>, ${stateGeo.geoName!}</#if> ${postalAddress.postalCode!}
                        </fo:block>
                        <fo:block>
                            <#assign countryGeo = (delegator.findOne("Geo", {"geoId", postalAddress.countryGeoId!}, false))! />
                            <#if countryGeo?has_content>${countryGeo.geoName!}</#if>
                        </fo:block>
                    </fo:block>                
                </#if>
            <#else>
                <#-- here we just display the name of the vendor, since there is no address -->
                <#assign vendorParty = orderReadHelper.getBillFromParty()>
                <fo:block>
                    <fo:inline font-weight="bold">${uiLabelMap.OrderPurchasedFrom}:</fo:inline> ${Static['org.ofbiz.party.party.PartyHelper'].getPartyName(vendorParty)}
                </fo:block>
            </#if>
        </#if>
        <#-- list all postal addresses of the order.  there should be just a billing and a shipping here. -->
        <#list orderContactMechValueMaps as orderContactMechValueMap>
            <fo:block margin-bottom="2mm">
            <#assign contactMech = orderContactMechValueMap.contactMech>
            <#assign contactMechPurpose = orderContactMechValueMap.contactMechPurposeType>
            <#if contactMech.contactMechTypeId == "POSTAL_ADDRESS">
                <#assign postalAddress = orderContactMechValueMap.postalAddress>
                <fo:block font-weight="bold">${contactMechPurpose.get("description",locale)}:</fo:block>
                <fo:block>
                    <#if postalAddress?has_content>
                        <#if postalAddress.toName?has_content><fo:block>${postalAddress.toName!}</fo:block></#if>
                        <#if postalAddress.attnName?has_content><fo:block>${postalAddress.attnName!}</fo:block></#if>
                        <fo:block>${postalAddress.address1!}</fo:block>
                        <#if postalAddress.address2?has_content><fo:block>${postalAddress.address2!}</fo:block></#if>
                        <fo:block>
                            <#assign stateGeo = (delegator.findOne("Geo", {"geoId", postalAddress.stateProvinceGeoId!}, false))! />
                            ${postalAddress.city}<#if stateGeo?has_content>, ${stateGeo.geoName!}</#if> ${postalAddress.postalCode!}
                        </fo:block>
                        <fo:block>
                            <#assign countryGeo = (delegator.findOne("Geo", {"geoId", postalAddress.countryGeoId!}, false))! />
                            <#if countryGeo?has_content>${countryGeo.geoName!}</#if>
                        </fo:block>
                    </#if>
                </fo:block>
            </#if>
            </fo:block>
        </#list>
    </fo:block>
</fo:block>
</#escape>