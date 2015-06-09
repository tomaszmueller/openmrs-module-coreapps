<%
    config.contextModel.put("returnUrl", ui.thisUrl())
%>

<div class="contact-info-inline">
    <span>
        ${ ui.format(config.patient.personAddress).replace("\n", ", ")}
        <em id="coreapps-person-address">${ ui.message("coreapps.person.address")}</em>
    </span>
    <span class="left-margin">
        ${config.patient.telephoneNumber ?: ''}
        <em>${ ui.message("coreapps.person.telephoneNumber")}</em>
    </span>
    <% if(!config.hideEditDemographicsButton) { %>
    <small class="edit-info" class="left-margin">
        <%= ui.includeFragment("appui", "extensionPoint", [ id: "patientHeader.editPatientContactInfo", contextModel: config.contextModel ]) %>
    </small>
    <% } %>
</div>