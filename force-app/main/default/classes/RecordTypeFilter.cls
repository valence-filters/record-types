/**
 * Allows you to populate the RecordTypeId field on records inbound to Salesforce by interpreting a string value in the record's properties.
 */
global with sharing class RecordTypeFilter implements valence.SchemaAwareTransformationFilter, valence.ConfigurablePerMappingFilter {

	// ----------------------------------------
	// ----- ConfigurablePerMappingFilter -----
	// ----------------------------------------

	public String getMappingConfigurationLightningComponent() {
		return 'c:recordTypeFilterConfigurator';
	}

	public String getMappingConfigurationStructure() {
		return null;
	}

	public String explainMappingConfiguration(String configStr) {

		try {
			Configuration config = (Configuration)JSON.deserialize(configStr, Configuration.class);

			String explanation = '<p>The following values will assign a RecordType:</p><ul>{0}</ul>';
			String values = '';
			for(String key : config.values.keySet()) {
				values += '<li><strong>' + key + '</strong> => <em>' + config.values.get(key) + '</em></li>';
			}
			return String.format(explanation, new List<Object>{values});
		}
		catch(Exception e) {
			return '<p class="slds-theme_error">This configuration is malformed.</p>';
		}
	}

	// --------------------------------
	// ----- TransformationFilter -----
	// --------------------------------

	public Boolean validFor(valence.LinkContext context) {
		return true;
	}

	public void process(valence.LinkContext context, List<valence.RecordInFlight> records) {

		Map<valence.FieldPath, Configuration> configsBySourcePath = new Map<valence.FieldPath, Configuration>();
		Map<String, String> recordTypesByDevName = getRecordTypeIdsByDevName(context.linkTargetName);

		/*
		 * Assemble any configs that have been set up by admins.
		 */
		for(valence.Mapping mapping : context.mappings.values()) {

			// extract our configurations
			if(String.isNotBlank(mapping.configuration)) {
				try {
					Configuration config = (Configuration)JSON.deserialize(mapping.configuration, Configuration.class);
					configsBySourcePath.put(mapping.sourceFieldPath, config);
				}
				catch(Exception e) {
					throw new valence.FilterException('Cannot parse RecordTypeFilter configuration: ' + mapping.configuration, e);
				}
			}
		}

		// bail out if we didn't find any configurations for our filter
		if(configsBySourcePath.isEmpty()) {
			return;
		}

		/*
		 * Iterate through our records, using the configured mapping to populate RecordTypeId.
		 */
		for(valence.RecordInFlight record : records) {
			for(valence.FieldPath sourcePath : configsBySourcePath.keySet()) {
				Configuration config = configsBySourcePath.get(sourcePath);
				String value = (String)record.getOriginalProperty(sourcePath);
				// attempt to set the RecordTypeId using a DeveloperName that was configured to match this field value
				if(value != null && config != null && config.values != null && recordTypesByDevName.get(config.values.get(value)) != null) {
					record.setProperty(valence.FieldPath.buildPath('RecordTypeId'), recordTypesByDevName.get(config.values.get(value)));
				}
			}
		}
	}

	// -------------------------------------------
	// ----- SchemaAwareTransformationFilter -----
	// -------------------------------------------

	public valence.FilterSchema describeSchema(valence.LinkContext context) {
		valence.FilterSchema schema = new valence.FilterSchema();
		schema.addTouch(valence.FilterSchema.buildTargetTouch('WRITE').onField(new List<String>{
			'RecordTypeId'
		}));
		return schema;
	}

	// -------------------
	// ----- Utility -----
	// -------------------

	/**
	 * Controller method available to our LWC configurator so it can offer a selection of record types to the yser.
	 *
	 * @param objectName The SObject to get Record Types for
	 *
	 * @return A list of record types associated with a particular object
	 */
	@AuraEnabled(Cacheable=true)
	public static List<RecordType> getTypesForObject(String objectName) {
		return [SELECT Id, DeveloperName, Name FROM RecordType WHERE SobjectType = :objectName];
	}

	private static Map<String, String> getRecordTypeIdsByDevName(String objectName) {
		Map<String, String> recordTypesByDevName = new Map<String, Id>();
		for(RecordType recordType : getTypesForObject(objectName)) {
			recordTypesByDevName.put(recordType.DeveloperName, recordType.Id);
		}

		if(Test.isRunningTest()) {
			// for tests, use some fake record types
			return new Map<String, String>{
				'SpaceEx' => 'SpaceExId', 'Ling' => 'LingId', 'DeepSea' => 'DeepSeaId'
			};
		}

		return recordTypesByDevName;
	}

	/**
	 * Simple class for holding the configuration needed for this filter.
	 */
	private class Configuration {

		private Map<String, String> values = new Map<String, String>();
	}
}