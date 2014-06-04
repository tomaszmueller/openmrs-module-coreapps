<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("coreapps", "adt/awaitingAdmission.css")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("coreapps.app.awaitingAdmission.label")}"}
    ];

    var supportsAdmissionLocationTag = '${supportsAdmissionLocationTag}';
    var supportsLoginLocationTag = '${supportsLoginLocationTag}';

    // TODO: probably want replace the whole thing with either ngGrid or the new datatable widget
    // TODO: make this more robust--kind of hacky to rely on column index now that it can change
    var admitToLocationColumnIndex = ${ paperRecordIdentifierDefinitionAvailable ? '5' : '4' };
    var currentLocationColumnIndex = ${ paperRecordIdentifierDefinitionAvailable ? '3' : '2' };

    jq(document).ready(function() {

        // these variables are updated in the change handler and referenced in the filter added in afnFiltering
        var admitToLocationFilter = jq("#inpatients-filterByAdmitToLocation select option:selected").text().replace(/'/g, "\\’");
        var currentLocationFilter = jq("#inpatients-filterByCurrentLocation select option:selected").text().replace(/'/g, "\\’");

        // this whole hack-around is for the problem with filtering with elements that have a single quote
        // this adds filter that filters based on the current values of the admitToLocationFilter and currentLocationFilter variables
        // it is triggered when we call the fnDraw() method in the change event handlers below
        jq.fn.dataTableExt.afnFiltering.push(
                function (oSettings, aData, iDataIndex) {

                    // remove single quote
                    var admitToLocation = aData[admitToLocationColumnIndex].replace(/'/g, "\\’");

                    if (admitToLocationFilter.length > 1) {
                        if (!admitToLocation.match(new RegExp(admitToLocationFilter))) {
                            return false;
                        }
                    }

                    var currentLocation = aData[currentLocationColumnIndex].replace(/'/g, "\\’");

                    if (currentLocationFilter.length > 1) {
                        if (!currentLocation.match(new RegExp(currentLocationFilter))) {
                            return false;
                        }
                    }

                    return true;
                }
        );

        // update the admitToLocationFilter and redisplay table when that filter dropdoown is changed
        jq("#inpatients-filterByAdmitToLocation").change(function(event){
            admitToLocationFilter = jq("#inpatients-filterByAdmitToLocation select option:selected").text().replace(/'/g, "\\’");
            jq('#awaiting-admission').dataTable({ "bRetrieve": true }).fnDraw();
        });

        // update the currentLocationFilter and redisplay table when that filter dropdoown is changed
        jq("#inpatients-filterByCurrentLocation").change(function(event){
            currentLocationFilter = jq("#inpatients-filterByCurrentLocation select option:selected").text().replace(/'/g, "\\’");
            jq('#awaiting-admission').dataTable({ "bRetrieve": true }).fnDraw();
        });

    });



</script>

<h2>${ ui.message("coreapps.app.awaitingAdmission.title") }</h2>

<div class="inpatient-current-location-filter">
    ${ ui.includeFragment("uicommons", "field/location", [
            "id": "inpatients-filterByCurrentLocation",
            "formFieldName": "filterByCurentLocationId",
            "label": "coreapps.app.awaitingAdmission.filterByCurrent",
            "withTag": supportsLoginLocationTag
    ] ) }
</div>

<div class="inpatient-admitTo-location-filter">
    ${ ui.includeFragment("uicommons", "field/location", [
            "id": "inpatients-filterByAdmitToLocation",
            "formFieldName": "filterByAdmitToLocationId",
            "label": "coreapps.app.awaitingAdmission.filterByAdmittedTo",
            "withTag": supportsAdmissionLocationTag,
            "initialValue": sessionContext.sessionLocation
    ] ) }
</div>

<table id="awaiting-admission" width="100%" border="1" cellspacing="0" cellpadding="2">
    <thead>
    <tr>
        <th>${ ui.message("coreapps.patient.identifier") }</th>
        <% if (paperRecordIdentifierDefinitionAvailable) { %>
            <th>${ ui.message("paperrecord.archivesRoom.recordNumber.label") }</th>
        <% } %>
        <th>${ ui.message("coreapps.person.name") }</th>
        <th>${ ui.message("coreapps.app.awaitingAdmission.currentWard") }</th>
        <th>${ ui.message("coreapps.app.awaitingAdmission.provider") }</th>
        <th>${ ui.message("coreapps.app.awaitingAdmission.admissionLocation") }</th>
        <th>${ ui.message("coreapps.app.awaitingAdmission.diagnosis") }</th>
        <th>${ ui.message("coreapps.app.awaitingAdmission.admitPatient") }</th>

    </tr>
    </thead>
    <tbody>
    <% if ((awaitingAdmissionList == null) || (awaitingAdmissionList != null && awaitingAdmissionList.size() == 0)) { %>
    <tr>
        <td colspan="8">${ ui.message("coreapps.none") }</td>
    </tr>
    <% } %>
    <% awaitingAdmissionList.each { v ->
        def patientId = v.patientId
        def visitId = v.visitId
    %>
    <tr id="visit-${ v.patientId
    }">
        <td>${ v.primaryIdentifier ? ui.format(v.primaryIdentifier) : ''}</td>
        <% if (paperRecordIdentifierDefinitionAvailable) { %>
            <td>${ v.paperRecordIdentifier ? ui.format(v.paperRecordIdentifier) : ''}</td>
        <% } %>
        <td>
            <a href="${ ui.pageLink("coreapps", "patientdashboard/patientDashboard", [ patientId: v.patientId ]) }">
                ${ ui.format((v.patientFirstName ? v.patientFirstName : '') + " " + (v.patientLastName ? v.patientLastName : '')) }
            </a>
        </td>

        <td>
            ${ ui.format(v.mostRecentAdmissionRequestFromLocation) }
            <br/>
            <small>
                ${ ui.format(v.mostRecentAdmissionRequestDatetime)}
            </small>
        </td>
        <td>
            ${ ui.format(v.mostRecentAdmissionRequestProvider) }
        </td>
        <td>${ ui.format(v.mostRecentAdmissionRequestToLocation) }</td>
        <td>
            <% v.mostRecentAdmissionRequestDiagnoses.each { %>
                ${ ui.format(it.diagnosis.codedAnswer ?: it.diagnosis.nonCodedAnswer) }${ it != v.mostRecentAdmissionRequestDiagnoses.last() ? ', ' : '' }
            <% } %>
        </td>
        <td>
            <% admissionActions.each { task ->
                def url = task.url.replaceAll('\\{\\{patientId\\}\\}', patientId.toString())
                url = url.replaceAll('\\{\\{visit.id\\}\\}', visitId.toString())
            %>
            <a href="/${ contextPath }/${ url }" class="">
                <i class="${task.icon}"></i> ${ ui.message(task.label) }</a>
            <% } %>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>

<% if ( (awaitingAdmissionList != null) && (awaitingAdmissionList.size() > 0) ) { %>
${ ui.includeFragment("uicommons", "widget/dataTable", [ object: "#awaiting-admission",
        options: [
                bFilter: true,
                bJQueryUI: true,
                bLengthChange: false,
                iDisplayLength: 10,
                sPaginationType: '\"full_numbers\"',
                bSort: false,
                sDom: '\'ft<\"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg \"ip>\''
        ]
]) }
<% } %>