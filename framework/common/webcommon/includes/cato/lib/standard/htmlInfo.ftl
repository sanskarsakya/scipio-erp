<#--
* 
* Informational/notification element HTML template include, standard Cato markup.
*
* Included by htmlTemplate.ftl.
*
* NOTE: May have implicit dependencies on other parts of Cato API.
*
-->

<#-- 
*************
* Modal
************
  * Usage Example *  
    <@modal id="dsadsa" attr="" >
        Modal Content 
    </@modal>        
            
  * Parameters *
    id              = set id (required)
    label           = set anchor text (required)
    icon            = generates icon inside the link (Note: has to be the full set of classes, e.g. "fa fa-fw fa-info")
-->
<#assign modal_defaultArgs = {
  "id":"", "label":"", "href":"", "icon":"", "passArgs":{}
}>
<#macro modal args={} inlineArgs...>
  <#local args = mergeArgMaps(args, inlineArgs, catoStdTmplLib.modal_defaultArgs)>
  <#local dummy = localsPutAll(args)>
  <#local origArgs = args>
  <@modal_markup id=id label=label href=href icon=icon origArgs=origArgs passArgs=passArgs><#nested></@modal_markup>
</#macro>

<#-- @modal main markup - theme override -->
<#macro modal_markup id="" label="" href="" icon="" origArgs={} passArgs={} catchArgs...>
  <a href="#" data-reveal-id="${id}_modal"<#if href?has_content> data-reveal-ajax="${href!}"</#if>><#if icon?has_content><i class="${icon!}"></i> </#if>${label}</a>
  <div id="${id}_modal" class="${styles.modal_wrap!}" data-reveal>
    <#nested>
    <a class="close-reveal-modal">&#215;</a>
  </div>
</#macro>

<#-- 
*************
* Alert box
************
Alert box for messages that must grab user attention.
NOTE: Should avoid using this for regular, common inlined message results such as "No records found." unless
    it's an unexpected result, error or one that requires user action.
    For most cases, it is preferrable to use @commonMsg macro because it is higher-level.

  * Usage Example *  
    <@alert type="info">
        This is an alert!
    </@alert>            
                    
  * Parameters *
    type           = (info|success|warning|secondary|alert|error), default info
    class          = classes or additional classes for nested container
                     supports prefixes:
                       "+": causes the classes to append only, never replace defaults (same logic as empty string "")
                       "=": causes the class to replace non-essential defaults (same as specifying a class name directly)
-->
<#assign alert_defaultArgs = {
  "type":"info", "class":"", "id":"", "passArgs":{}
}>
<#macro alert args={} inlineArgs...>
  <#local args = mergeArgMaps(args, inlineArgs, catoStdTmplLib.alert_defaultArgs)>
  <#local dummy = localsPutAll(args)>
  <#local origArgs = args>
  <#local typeClass = "alert_type_${type!}"/>
  <#if type="error">
    <#local type = "alert">
  </#if>
  <@alert_markup type=type class=class typeClass=typeClass id=id origArgs=origArgs passArgs=passArgs><#nested></@alert_markup>
</#macro>

<#-- @alert main markup - theme override -->
<#macro alert_markup type="info" class="" typeClass="" id="" origArgs={} passArgs={} catchArgs...>
  <#local class = addClassArg(class, styles.grid_cell!"")>
  <#local class = addClassArgDefault(class, "${styles.grid_large!}12")>
  <div class="${styles.grid_row!}"<#if id?has_content> id="${id}"</#if>>
    <div class="${styles.grid_large!}12 ${styles.grid_cell!}">
      <div data-alert class="${styles.alert_wrap!} ${styles[typeClass]!}">
        <div class="${styles.grid_row!}">
          <div<@compiledClassAttribStr class=class />>
            <a href="#" class="close" data-dismiss="alert">&times;</a>
            <#nested>
          </div>
        </div>
      </div>
    </div>
  </div>
</#macro>

<#--
*************
* Panel box
************
  * Usage Example *  
    <@panel type="">
        This is a panel.
    </@panel>            
                    
  * Parameters *
    type           = (callout|) default:empty
    title          = Title
-->
<#assign panel_defaultArgs = {
  "type":"", "title":"", "passArgs":{}
}>
<#macro panel args={} inlineArgs...>
  <#local args = mergeArgMaps(args, inlineArgs, catoStdTmplLib.panel_defaultArgs)>
  <#local dummy = localsPutAll(args)>
  <#local origArgs = args>
  <@panel_markup type=type title=title origArgs=origArgs passArgs=passArgs><#nested></@panel_markup>
</#macro>

<#-- @panel main markup - theme override -->
<#macro panel_markup type="" title="" origArgs={} passArgs={} catchArgs...>
  <div class="${styles.panel_wrap!} ${type}">
    <div class="${styles.panel_head!}"><#if title?has_content><h5 class="${styles.panel_title!}">${title!}</h5></#if></div>
    <div class="${styles.panel_body!}"><p><#nested></p></div>
  </div>
</#macro>

<#-- 
*************
* Common messages (abstraction)
************
Abstracts and factors out the display format of common messages of specific meanings, such as
errors (e.g. permission errors) and query results (e.g. "No records found." messages).
In other words, labels messages according to what they are and lets the theme decide on markup and styling based on content.

This is higher-level than @alert macro; @alert has a specific markup/display and its types are usually levels of severity,
whereas @commonMsg abstracts markup/display and its messages can be a combination of levels and specific meanings;
@alert's goal is to grab user attention, whereas @commonMsg's behavior depends on the type of message.

@commonMsg may use @alert to implement its markup.
A template should not assume too much about the message markup, but the markup should be kept simple.

WIDGETS: <label.../> elements in screen widgets can be mapped to this macro using the special "common-msg-xxx" style name, where
    xxx is the message type. e.g.: 
      <label style="common-msg-error-perm" text="Permission Error" />
    translates to:
      <@commonMsg type="error-perm">Permission Error</@commonMsg>
    Extra classes are also possible using colon syntax (combined with the usual "+" macro additive class instruction):
      <label style="common-msg-error-perm:+myclass" text="Permission Error" />
    translates to:
      <@commonMsg type="error-perm" class="+myclass">Permission Error</@commonMsg>
      
  * Usage Example *  
    <@commonMsg type="result-norecord"/>            
             
  * Parameters *
    type        = [default|generic|...], default default - the type of message contained.
                  Basic types:
                    default: default. in standard Cato markup, same as generic.
                    generic: no type specified (avoid using - prefer more specific)
                  Types recognizes by Cato standard markup (theme-defined types are possible):
                    result: an informational result from any kind of query. e.g., "No records found.".
                        is a normal event that shouldn't distract user attention.
                    result-norecord: specific "No records found." message.
                    info: general information (NOTE: this is not really useful, but supported for completeness)
                    info-important: general important information
                    warning: general warning
                    fail: general non-fatal error
                    error: general error message - typically an unexpected event or fatal error that should not happen in intended use.
                    error-perm: permission error
                    error-security: security error
    id          = id
    class       = classes or additional classes for message container (innermost containing element)
                  (if boolean, true means use defaults, false means prevent non-essential defaults; prepend with "+" to append-only, i.e. never replace non-essential defaults)
    text        = text. If string not specified, uses #nested instead.
-->
<#assign commonMsg_defaultArgs = {
  "type":"", "class":"", "id":"", "text":true, "passArgs":{}
}>
<#macro commonMsg args={} inlineArgs...>
  <#local args = mergeArgMaps(args, inlineArgs, catoStdTmplLib.commonMsg_defaultArgs)>
  <#local dummy = localsPutAll(args)>
  <#local origArgs = args>
  <#if !type?has_content>
    <#local type = "default">
  </#if>
  <#local styleNamePrefix = "commonmsg_" + type?replace("-", "_")>
  <#local defaultClass = styles[styleNamePrefix]!styles["commonmsg_default"]>
  <#local class = addClassArgDefault(class, defaultClass)>
  <@commonMsg_markup type=type styleNamePrefix=styleNamePrefix class=class id=id origArgs=origArgs passArgs=passArgs><#if !text?is_boolean>${text}<#elseif !(text?is_boolean && text == false)><#nested></#if></@commonMsg_markup>
</#macro>

<#-- @commonMsg main markup - theme override -->
<#macro commonMsg_markup type="" styleNamePrefix="" class="" id="" origArgs={} passArgs={} catchArgs...>
  <#if type == "result" || type?starts_with("result-") || type == "info">
    <#local nestedContent><#nested></#local>
    <#local nestedContent = nestedContent?trim> <#-- helpful in widgets -->
    <#if !nestedContent?has_content>
      <#local nestedContent = uiLabelMap[styles.commonmsg_result_norecord_prop!"CommonNoRecordFoundSentence"]>
    </#if>
    <p<@compiledClassAttribStr class=class /><#if id?has_content> id="${id}"</#if>>${nestedContent}</p>
  <#elseif type == "error" || type?starts_with("error-")>
    <#-- NOTE: here we must resolve class arg before passing to @alert and make additive only -->
    <@alert type="error" class=("+"+compileClassArg(class)) id=id><#nested></@alert>
  <#elseif type == "fail">
    <@alert type="error" class=("+"+compileClassArg(class)) id=id><#nested></@alert>
  <#elseif type == "warning">
    <@alert type="warning" class=("+"+compileClassArg(class)) id=id><#nested></@alert>
  <#elseif type == "info-important">
    <@alert type="info" class=("+"+compileClassArg(class)) id=id><#nested></@alert>
  <#else>
    <p<@compiledClassAttribStr class=class /><#if id?has_content> id="${id}"</#if>><#nested></p>
  </#if>
</#macro>



