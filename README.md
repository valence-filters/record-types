# Record Types

This is a custom extension for <a href="https://valence.app">Valence</a>, a <a href="https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000EORP4UAP">managed package on the Salesforce AppExchange</a> that provides integration middleware natively in a Salesforce org.

To learn more about developing extensions for the Valence platform, check out <a href="https://docs.valence.app">the Valence documentation</a>.

## Installing

Click this button to install the filter into your org.

<a href="https://githubsfdeploy.herokuapp.com?owner=valence-filters&repo=record-types&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## What Does This Filter Do?

Allows you to populate the RecordTypeId field on records inbound to Salesforce by interpreting a string value in the record's properties.

You configure the Filter by attaching it to a mapping and matching sample values you would receive from the external system with the appropriate Record Type to map those values into.

The configurations are stored using the DeveloperName of the Record Type, so no concerns about Record Type Ids not matching across environments. As long as your DeveloperNames match, you can easily move these configurations between orgs.

### Configuring the Filter

![You can pick each Record Type from a dropdown](/images/configuring.png)

### What You See Once Configured

![Each configuration shows you what matches were selected](/images/explainer.png)

### Effect on Records

At runtime this Filter will attempt to match the incoming value on the mapping to one of the configured values, and if a match is found (and there is a Record Type with the configured DeveloperName in this org) then the appropriate RecordType Id will be written to the SObject before it goes into the database.

If a match is not found, the RecordTypeId field is left alone.

![Records have their RecordTypeId field populated](/images/results.png)
