/**
 * Exercises the RecordTypeFilter class.
 */
@IsTest
private class RecordTypeFilterTests {

	@IsTest static void testRestrictions() {

		System.assertEquals(true, new RecordTypeFilter().validFor(null));
	}

}
