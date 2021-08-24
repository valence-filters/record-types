/**
 * Allows you to populate the RecordTypeId field on records inbound to Salesforce by interpreting a string value in the record's properties.
 */
global with sharing class RecordTypeFilter implements valence.TransformationFilter {

	public Boolean validFor(valence.LinkContext context) {
		return true;
	}

	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {

	}
}
