package ngio.data;

enum abstract PeriodData(String) to String from String {
	
	/** Indicates scores are from the current day. */
	var DAY = "D";
	/** Indicates scores are from the current week. */
	var WEEK = "W";
	/** Indicates scores are from the current month. */
	var MONTH = "M";
	/** Indicates scores are from the current year. */
	var YEAR = "Y";
	/** Indicates scores are from all-time. */
	var ALL = "A";
}