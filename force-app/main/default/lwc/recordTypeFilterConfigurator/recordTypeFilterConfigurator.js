/**
 * Allows a user to configure the RecordType filter for Valence.
 */

import {LightningElement} from 'lwc';
import ValenceUIConfigurator from 'c/valenceUIConfigurator';
import getTypesForObject from '@salesforce/apex/RecordTypeFilter.getTypesForObject';

export default class RecordTypeFilterConfigurator extends ValenceUIConfigurator {

	recordTypes = [];

	// ---------------------------
	// ----- Lifecycle Hooks -----
	// ---------------------------

	onSetLink() {
		// once we know the link details, fetch all record types related to the target SObject so we can offer them to the user
		getTypesForObject({objectName : this.link.targetName})
		.then(data => {
			this.recordTypes = data.map(recordType => {
				return {'value' : recordType.DeveloperName, 'label' : recordType.Name};
			});
		})
		.catch(error => console.error(error));
	}

	/**
	 * Because we store our configuration values as a map and LWCs can't iterate a map, we fiddle the configuration a little on the way in and the way out.
	 */
	onSetConfiguration() {
		// massage server-friendly format into LWC-friendly format
		this.configuration.pairs = Object.entries(this.configuration.values).map(([key, value]) => {
			return {'value' : key, 'recordType' : value};
		});
	}

	/**
	 * This is called just before sending the configuration up the chain. We return a simplified version of configuration since we added stuff to it.
	 */
	tweakConfiguration() {
		// turn massaged values back into something the server wants
		return {
			'values' : this.configuration.pairs.reduce((values, pair) => {
				values[pair.value] = pair.recordType;
				return values;
			}, {})
		};
	}

	// -------------------------------------------
	// ----- User Manipulating Configuration -----
	// -------------------------------------------

	addPair() {
		this.configuration.pairs.push({'value' : '', 'recordType' : ''});
		this.configUpdated(); // propagate our configuration changes
	}

	removePair(event) {
		this.configuration.pairs.splice(event.target.value, 1);
		this.configUpdated(); // propagate our configuration changes
	}

	updateIncomingValue(event) {
		this.configuration.pairs[event.target.dataset.index].value = event.target.value;
		this.configUpdated(); // propagate our configuration changes
	}

	updateRecordType(event) {
		this.configuration.pairs[event.target.dataset.index].recordType = event.target.value;
		this.configUpdated(); // propagate our configuration changes
	}

	// -----------------------------------------
	// ----- Required Configurator Methods -----
	// -----------------------------------------

	getDefaultShape() {
		return {values : {}};
	}

	computeValid() {
		if(!this.configuration.values || this.configuration.values.length === 0) {
			return false;
		}
		// make sure each pair has both sides populated to be considered valid
		return this.configuration.pairs.reduce((validSoFar, next) => validSoFar && next.value && next.recordType, true);
	}
}