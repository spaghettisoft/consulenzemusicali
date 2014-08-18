<master>
<property name="title">@page_title@</property>
<property name="context">@context;noquote@</property>

<formtemplate id="addedit"></formtemplate>
<br/>
<if @new_record_p@ eq 0 >
  <listtemplate name="translations"></listtemplate>
</if>



