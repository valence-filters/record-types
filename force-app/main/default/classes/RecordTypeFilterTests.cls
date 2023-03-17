/**
 * Exercises the RecordTypeFilter class.
 */
@IsTest
private class RecordTypeFilterTests {

	@IsTest static void testBehavior() {

		String configStr = JSON.serialize(new Map<String, Object>{
				'values' => new Map<String, String>{'Space Exploration' => 'SpaceEx', 'Linguistics' => 'Ling'}
		});

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkTargetName = 'Contact';
		context.mappings = new Map<String, valence.Mapping>{
				'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Industry', 'Department', configStr)
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Space Exploration'}, new Map<String, Object>()),
			valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Agriculture'}, new Map<String, Object>()),
			valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Linguistics'}, new Map<String, Object>())
		};

		RecordTypeFilter filter = new RecordTypeFilter();
		filter.process(context, records);

		System.assertEquals('SpaceExId', records[0].getProperties().get('RecordTypeId'));

		System.assert(!records[1].getProperties().containsKey('RecordTypeId'));

		System.assertEquals('LingId', records[2].getProperties().get('RecordTypeId'));
	}

	@IsTest static void testBehaviorBadConfig() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkTargetName = 'Contact';
		context.mappings = new Map<String, valence.Mapping>{
			'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Industry', 'Department', 'invalid')
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
			valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Space Exploration'}, new Map<String, Object>()),
			valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Agriculture'}, new Map<String, Object>()),
			valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Linguistics'}, new Map<String, Object>())
		};

		RecordTypeFilter filter = new RecordTypeFilter();
		try {
			filter.process(context, records);
			System.assert(false, 'Expected an exception due to the malformed configuration.');
		}catch(Exception e) {
			System.assertEquals('valence.FilterException',e.getTypeName());
			System.assertEquals('Cannot parse RecordTypeFilter configuration: invalid',e.getMessage());
			System.assertNotEquals(null, e.getCause());
		}
	}

	@IsTest static void testBehaviorNoConfigs() {

		// setup up an artificial Context to use for our test
		valence.LinkContext context = new valence.LinkContext();
		context.linkTargetName = 'Contact';
		context.mappings = new Map<String, valence.Mapping>{
				'firstMapping' => valence.ValenceTestUtil.createTestMapping('firstMapping', 'Industry', 'Department', null)
		};

		List<valence.RecordInFlight> records = new List<valence.RecordInFlight>{
				valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Space Exploration'}, new Map<String, Object>()),
				valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Agriculture'}, new Map<String, Object>()),
				valence.ValenceTestUtil.createTestRecordInFlight(new Map<String, Object>{'Industry' => 'Linguistics'}, new Map<String, Object>())
		};

		RecordTypeFilter filter = new RecordTypeFilter();
		filter.process(context, records);

		System.assert(!records[0].getProperties().containsKey('RecordTypeId'));
		System.assert(!records[1].getProperties().containsKey('RecordTypeId'));
		System.assert(!records[2].getProperties().containsKey('RecordTypeId'));
	}

	@IsTest static void testRestrictions() {

		System.assertEquals(true, new RecordTypeFilter().validFor(null));
	}

	@IsTest static void testDescribeSchema() {

		// not really a way to test this atm
		new RecordTypeFilter().describeSchema(null);
	}

	@IsTest static void testConfigurationMethods() {

		RecordTypeFilter filter = new RecordTypeFilter();

		System.assertNotEquals(null, filter.getMappingConfigurationLightningComponent());
		System.assertEquals(null, filter.getMappingConfigurationStructure());

		String config = JSON.serialize(new Map<String, Object>{
				'values' => new Map<String, String>{'Space Exploration' => 'SpaceEx', 'Linguistics' => 'Ling'}
		});

		System.assertEquals('<p>The following values will assign a RecordType:</p><ul><li><strong>Linguistics</strong> => <em>Ling</em></li><li><strong>Space Exploration</strong> => <em>SpaceEx</em></li></ul>', filter.explainMappingConfiguration(config));

		System.assertEquals('<p class="slds-theme_error">This configuration is malformed.</p>', filter.explainMappingConfiguration('invalid'));
	}
}