/************************************************************************/
/* Initialises the Timezones table with some actual timezones.		*/
/* Unfortunately the system table pg_timezone_names contains too much	*/
/* cruft.  The data contained in this file is therefore taken from	*/
/* /usr/share/zoneinfo/zone.tab						*/
/************************************************************************/

CREATE FUNCTION add_timezone (text)
RETURNS VOID
LANGUAGE plpgsql VOLATILE AS
$$
DECLARE
	_name		ALIAS FOR $1;
	_abbrev		text;
	_raw_offset	interval;
	_hours		float;
	_minutes	float;
	_offset		float;
	_dst		boolean;

BEGIN
	SELECT	INTO _abbrev, _raw_offset, _dst
		abbrev, utc_offset, is_dst
		FROM pg_timezone_names
		WHERE name = _name;

	_hours := extract (hour FROM _raw_offset);
	_minutes := extract (minute FROM _raw_offset);
	_offset := (_hours * 60.0 + _minutes) / 60.0;

	RAISE NOTICE 'Adding % timezone (%, %, %)...', _name, _abbrev, _offset, _dst;

	INSERT	INTO timezones (timezone_name, timezone_abbrev, timezone_offset, timezone_dst)
		VALUES (_name, _abbrev, _offset, _dst);
END
$$;

SELECT add_timezone ('Africa/Abidjan');
SELECT add_timezone ('Africa/Accra');
SELECT add_timezone ('Africa/Addis_Ababa');

/*
SELECT add_timezone ('Africa/Algiers');
SELECT add_timezone ('Africa/Asmara');
SELECT add_timezone ('Africa/Bamako');
SELECT add_timezone ('Africa/Bangui');
SELECT add_timezone ('Africa/Banjul');
SELECT add_timezone ('Africa/Bissau');
SELECT add_timezone ('Africa/Blantyre');
SELECT add_timezone ('Africa/Brazzaville');
SELECT add_timezone ('Africa/Bujumbura');
SELECT add_timezone ('Africa/Cairo');
SELECT add_timezone ('Africa/Casablanca');
SELECT add_timezone ('Africa/Ceuta');
SELECT add_timezone ('Africa/Conakry');
SELECT add_timezone ('Africa/Dakar');
SELECT add_timezone ('Africa/Dar_es_Salaam');
SELECT add_timezone ('Africa/Djibouti');
SELECT add_timezone ('Africa/Douala');
SELECT add_timezone ('Africa/El_Aaiun');
SELECT add_timezone ('Africa/Freetown');
SELECT add_timezone ('Africa/Gaborone');
SELECT add_timezone ('Africa/Harare');
SELECT add_timezone ('Africa/Johannesburg');
SELECT add_timezone ('Africa/Kampala');
SELECT add_timezone ('Africa/Khartoum');
SELECT add_timezone ('Africa/Kigali');
SELECT add_timezone ('Africa/Kinshasa');
SELECT add_timezone ('Africa/Lagos');
SELECT add_timezone ('Africa/Libreville');
SELECT add_timezone ('Africa/Lome');
SELECT add_timezone ('Africa/Luanda');
SELECT add_timezone ('Africa/Lubumbashi');
SELECT add_timezone ('Africa/Lusaka');
SELECT add_timezone ('Africa/Malabo');
SELECT add_timezone ('Africa/Maputo');
SELECT add_timezone ('Africa/Maseru');
SELECT add_timezone ('Africa/Mbabane');
SELECT add_timezone ('Africa/Mogadishu');
SELECT add_timezone ('Africa/Monrovia');
SELECT add_timezone ('Africa/Nairobi');
SELECT add_timezone ('Africa/Ndjamena');
SELECT add_timezone ('Africa/Niamey');
SELECT add_timezone ('Africa/Nouakchott');
SELECT add_timezone ('Africa/Ouagadougou');
SELECT add_timezone ('Africa/Porto-Novo');
SELECT add_timezone ('Africa/Sao_Tome');
SELECT add_timezone ('Africa/Tripoli');
SELECT add_timezone ('Africa/Tunis');
SELECT add_timezone ('Africa/Windhoek');
SELECT add_timezone ('America/Adak');
SELECT add_timezone ('America/Anchorage');
SELECT add_timezone ('America/Anguilla');
SELECT add_timezone ('America/Antigua');
SELECT add_timezone ('America/Araguaina');
SELECT add_timezone ('America/Argentina/Buenos_Aires');
SELECT add_timezone ('America/Argentina/Catamarca');
SELECT add_timezone ('America/Argentina/Cordoba');
SELECT add_timezone ('America/Argentina/Jujuy');
SELECT add_timezone ('America/Argentina/La_Rioja');
SELECT add_timezone ('America/Argentina/Mendoza');
SELECT add_timezone ('America/Argentina/Rio_Gallegos');
SELECT add_timezone ('America/Argentina/San_Juan');
SELECT add_timezone ('America/Argentina/Tucuman');
SELECT add_timezone ('America/Argentina/Ushuaia');
SELECT add_timezone ('America/Aruba');
SELECT add_timezone ('America/Asuncion');
SELECT add_timezone ('America/Atikokan');
SELECT add_timezone ('America/Bahia');
SELECT add_timezone ('America/Barbados');
SELECT add_timezone ('America/Belem');
SELECT add_timezone ('America/Belize');
SELECT add_timezone ('America/Blanc-Sablon');
SELECT add_timezone ('America/Boa_Vista');
SELECT add_timezone ('America/Bogota');
SELECT add_timezone ('America/Boise');
SELECT add_timezone ('America/Cambridge_Bay');
SELECT add_timezone ('America/Campo_Grande');
SELECT add_timezone ('America/Cancun');
SELECT add_timezone ('America/Caracas');
SELECT add_timezone ('America/Cayenne');
SELECT add_timezone ('America/Cayman');
SELECT add_timezone ('America/Chicago');
SELECT add_timezone ('America/Chihuahua');
SELECT add_timezone ('America/Costa_Rica');
SELECT add_timezone ('America/Cuiaba');
SELECT add_timezone ('America/Curacao');
SELECT add_timezone ('America/Danmarkshavn');
SELECT add_timezone ('America/Dawson');
SELECT add_timezone ('America/Dawson_Creek');
SELECT add_timezone ('America/Denver');
SELECT add_timezone ('America/Detroit');
SELECT add_timezone ('America/Dominica');
SELECT add_timezone ('America/Edmonton');
SELECT add_timezone ('America/Eirunepe');
SELECT add_timezone ('America/El_Salvador');
SELECT add_timezone ('America/Fortaleza');
SELECT add_timezone ('America/Glace_Bay');
SELECT add_timezone ('America/Godthab');
SELECT add_timezone ('America/Goose_Bay');
SELECT add_timezone ('America/Grand_Turk');
SELECT add_timezone ('America/Grenada');
SELECT add_timezone ('America/Guadeloupe');
SELECT add_timezone ('America/Guatemala');
SELECT add_timezone ('America/Guayaquil');
SELECT add_timezone ('America/Guyana');
SELECT add_timezone ('America/Halifax');
SELECT add_timezone ('America/Havana');
SELECT add_timezone ('America/Hermosillo');
SELECT add_timezone ('America/Indiana/Indianapolis');
SELECT add_timezone ('America/Indiana/Knox');
SELECT add_timezone ('America/Indiana/Marengo');
SELECT add_timezone ('America/Indiana/Petersburg');
SELECT add_timezone ('America/Indiana/Tell_City');
SELECT add_timezone ('America/Indiana/Vevay');
SELECT add_timezone ('America/Indiana/Vincennes');
SELECT add_timezone ('America/Indiana/Winamac');
SELECT add_timezone ('America/Inuvik');
SELECT add_timezone ('America/Iqaluit');
SELECT add_timezone ('America/Jamaica');
SELECT add_timezone ('America/Juneau');
SELECT add_timezone ('America/Kentucky/Louisville');
SELECT add_timezone ('America/Kentucky/Monticello');
SELECT add_timezone ('America/La_Paz');
SELECT add_timezone ('America/Lima');
SELECT add_timezone ('America/Los_Angeles');
SELECT add_timezone ('America/Maceio');
SELECT add_timezone ('America/Managua');
SELECT add_timezone ('America/Manaus');
SELECT add_timezone ('America/Martinique');
SELECT add_timezone ('America/Mazatlan');
SELECT add_timezone ('America/Menominee');
SELECT add_timezone ('America/Merida');
SELECT add_timezone ('America/Mexico_City');
SELECT add_timezone ('America/Miquelon');
SELECT add_timezone ('America/Moncton');
SELECT add_timezone ('America/Monterrey');
SELECT add_timezone ('America/Montevideo');
SELECT add_timezone ('America/Montreal');
SELECT add_timezone ('America/Montserrat');
SELECT add_timezone ('America/Nassau');
SELECT add_timezone ('America/New_York');
SELECT add_timezone ('America/Nipigon');
SELECT add_timezone ('America/Nome');
SELECT add_timezone ('America/Noronha');
SELECT add_timezone ('America/North_Dakota/Center');
SELECT add_timezone ('America/North_Dakota/New_Salem');
SELECT add_timezone ('America/Panama');
SELECT add_timezone ('America/Pangnirtung');
SELECT add_timezone ('America/Paramaribo');
SELECT add_timezone ('America/Phoenix');
SELECT add_timezone ('America/Port-au-Prince');
SELECT add_timezone ('America/Port_of_Spain');
SELECT add_timezone ('America/Porto_Velho');
SELECT add_timezone ('America/Puerto_Rico');
SELECT add_timezone ('America/Rainy_River');
SELECT add_timezone ('America/Rankin_Inlet');
SELECT add_timezone ('America/Recife');
SELECT add_timezone ('America/Regina');
SELECT add_timezone ('America/Resolute');
SELECT add_timezone ('America/Rio_Branco');
SELECT add_timezone ('America/Santiago');
SELECT add_timezone ('America/Santo_Domingo');
SELECT add_timezone ('America/Sao_Paulo');
SELECT add_timezone ('America/Scoresbysund');
SELECT add_timezone ('America/Shiprock');
SELECT add_timezone ('America/St_Johns');
SELECT add_timezone ('America/St_Kitts');
SELECT add_timezone ('America/St_Lucia');
SELECT add_timezone ('America/St_Thomas');
SELECT add_timezone ('America/St_Vincent');
SELECT add_timezone ('America/Swift_Current');
SELECT add_timezone ('America/Tegucigalpa');
SELECT add_timezone ('America/Thule');
SELECT add_timezone ('America/Thunder_Bay');
SELECT add_timezone ('America/Tijuana');
SELECT add_timezone ('America/Toronto');
SELECT add_timezone ('America/Tortola');
SELECT add_timezone ('America/Vancouver');
SELECT add_timezone ('America/Whitehorse');
SELECT add_timezone ('America/Winnipeg');
SELECT add_timezone ('America/Yakutat');
SELECT add_timezone ('America/Yellowknife');
SELECT add_timezone ('Antarctica/Casey');
SELECT add_timezone ('Antarctica/Davis');
SELECT add_timezone ('Antarctica/DumontDUrville');
SELECT add_timezone ('Antarctica/Mawson');
SELECT add_timezone ('Antarctica/McMurdo');
SELECT add_timezone ('Antarctica/Palmer');
SELECT add_timezone ('Antarctica/Rothera');
SELECT add_timezone ('Antarctica/South_Pole');
SELECT add_timezone ('Antarctica/Syowa');
SELECT add_timezone ('Antarctica/Vostok');
SELECT add_timezone ('Arctic/Longyearbyen');
SELECT add_timezone ('Asia/Aden');
SELECT add_timezone ('Asia/Almaty');
SELECT add_timezone ('Asia/Amman');
SELECT add_timezone ('Asia/Anadyr');
SELECT add_timezone ('Asia/Aqtau');
SELECT add_timezone ('Asia/Aqtobe');
SELECT add_timezone ('Asia/Ashgabat');
SELECT add_timezone ('Asia/Baghdad');
SELECT add_timezone ('Asia/Bahrain');
SELECT add_timezone ('Asia/Baku');
SELECT add_timezone ('Asia/Bangkok');
SELECT add_timezone ('Asia/Beirut');
SELECT add_timezone ('Asia/Bishkek');
SELECT add_timezone ('Asia/Brunei');
SELECT add_timezone ('Asia/Calcutta');
SELECT add_timezone ('Asia/Choibalsan');
SELECT add_timezone ('Asia/Chongqing');
SELECT add_timezone ('Asia/Colombo');
SELECT add_timezone ('Asia/Damascus');
SELECT add_timezone ('Asia/Dhaka');
SELECT add_timezone ('Asia/Dili');
SELECT add_timezone ('Asia/Dubai');
SELECT add_timezone ('Asia/Dushanbe');
SELECT add_timezone ('Asia/Gaza');
SELECT add_timezone ('Asia/Harbin');
SELECT add_timezone ('Asia/Hong_Kong');
SELECT add_timezone ('Asia/Hovd');
SELECT add_timezone ('Asia/Irkutsk');
SELECT add_timezone ('Asia/Jakarta');
SELECT add_timezone ('Asia/Jayapura');
SELECT add_timezone ('Asia/Jerusalem');
SELECT add_timezone ('Asia/Kabul');
SELECT add_timezone ('Asia/Kamchatka');
SELECT add_timezone ('Asia/Karachi');
SELECT add_timezone ('Asia/Kashgar');
SELECT add_timezone ('Asia/Katmandu');
SELECT add_timezone ('Asia/Krasnoyarsk');
SELECT add_timezone ('Asia/Kuala_Lumpur');
SELECT add_timezone ('Asia/Kuching');
SELECT add_timezone ('Asia/Kuwait');
SELECT add_timezone ('Asia/Macau');
SELECT add_timezone ('Asia/Magadan');
SELECT add_timezone ('Asia/Makassar');
SELECT add_timezone ('Asia/Manila');
SELECT add_timezone ('Asia/Muscat');
SELECT add_timezone ('Asia/Nicosia');
SELECT add_timezone ('Asia/Novosibirsk');
SELECT add_timezone ('Asia/Omsk');
SELECT add_timezone ('Asia/Oral');
SELECT add_timezone ('Asia/Phnom_Penh');
SELECT add_timezone ('Asia/Pontianak');
SELECT add_timezone ('Asia/Pyongyang');
SELECT add_timezone ('Asia/Qatar');
SELECT add_timezone ('Asia/Qyzylorda');
SELECT add_timezone ('Asia/Rangoon');
SELECT add_timezone ('Asia/Riyadh');
SELECT add_timezone ('Asia/Saigon');
SELECT add_timezone ('Asia/Sakhalin');
SELECT add_timezone ('Asia/Samarkand');
SELECT add_timezone ('Asia/Seoul');
SELECT add_timezone ('Asia/Shanghai');
SELECT add_timezone ('Asia/Singapore');
SELECT add_timezone ('Asia/Taipei');
SELECT add_timezone ('Asia/Tashkent');
SELECT add_timezone ('Asia/Tbilisi');
SELECT add_timezone ('Asia/Tehran');
SELECT add_timezone ('Asia/Thimphu');
SELECT add_timezone ('Asia/Tokyo');
SELECT add_timezone ('Asia/Ulaanbaatar');
SELECT add_timezone ('Asia/Urumqi');
SELECT add_timezone ('Asia/Vientiane');
SELECT add_timezone ('Asia/Vladivostok');
SELECT add_timezone ('Asia/Yakutsk');
SELECT add_timezone ('Asia/Yekaterinburg');
SELECT add_timezone ('Asia/Yerevan');
SELECT add_timezone ('Atlantic/Azores');
SELECT add_timezone ('Atlantic/Bermuda');
SELECT add_timezone ('Atlantic/Canary');
SELECT add_timezone ('Atlantic/Cape_Verde');
SELECT add_timezone ('Atlantic/Faroe');
SELECT add_timezone ('Atlantic/Jan_Mayen');
SELECT add_timezone ('Atlantic/Madeira');
SELECT add_timezone ('Atlantic/Reykjavik');
SELECT add_timezone ('Atlantic/South_Georgia');
SELECT add_timezone ('Atlantic/Stanley');
SELECT add_timezone ('Atlantic/St_Helena');
SELECT add_timezone ('Australia/Adelaide');
SELECT add_timezone ('Australia/Brisbane');
SELECT add_timezone ('Australia/Broken_Hill');
SELECT add_timezone ('Australia/Currie');
SELECT add_timezone ('Australia/Darwin');
SELECT add_timezone ('Australia/Eucla');
SELECT add_timezone ('Australia/Hobart');
SELECT add_timezone ('Australia/Lindeman');
SELECT add_timezone ('Australia/Lord_Howe');
SELECT add_timezone ('Australia/Melbourne');
SELECT add_timezone ('Australia/Perth');
SELECT add_timezone ('Australia/Sydney');
SELECT add_timezone ('Europe/Amsterdam');
SELECT add_timezone ('Europe/Andorra');
SELECT add_timezone ('Europe/Athens');
SELECT add_timezone ('Europe/Belgrade');
SELECT add_timezone ('Europe/Berlin');
SELECT add_timezone ('Europe/Bratislava');
SELECT add_timezone ('Europe/Brussels');
SELECT add_timezone ('Europe/Bucharest');
SELECT add_timezone ('Europe/Budapest');
SELECT add_timezone ('Europe/Chisinau');
SELECT add_timezone ('Europe/Copenhagen');
SELECT add_timezone ('Europe/Dublin');
SELECT add_timezone ('Europe/Gibraltar');
SELECT add_timezone ('Europe/Guernsey');
SELECT add_timezone ('Europe/Helsinki');
SELECT add_timezone ('Europe/Isle_of_Man');
SELECT add_timezone ('Europe/Istanbul');
SELECT add_timezone ('Europe/Jersey');
SELECT add_timezone ('Europe/Kaliningrad');
SELECT add_timezone ('Europe/Kiev');
SELECT add_timezone ('Europe/Lisbon');
SELECT add_timezone ('Europe/Ljubljana');
SELECT add_timezone ('Europe/London');
SELECT add_timezone ('Europe/Luxembourg');
SELECT add_timezone ('Europe/Madrid');
SELECT add_timezone ('Europe/Malta');
SELECT add_timezone ('Europe/Mariehamn');
SELECT add_timezone ('Europe/Minsk');
SELECT add_timezone ('Europe/Monaco');
SELECT add_timezone ('Europe/Moscow');
SELECT add_timezone ('Europe/Oslo');
SELECT add_timezone ('Europe/Paris');
SELECT add_timezone ('Europe/Podgorica');
SELECT add_timezone ('Europe/Prague');
SELECT add_timezone ('Europe/Riga');
SELECT add_timezone ('Europe/Rome');
SELECT add_timezone ('Europe/Samara');
SELECT add_timezone ('Europe/San_Marino');
SELECT add_timezone ('Europe/Sarajevo');
SELECT add_timezone ('Europe/Simferopol');
SELECT add_timezone ('Europe/Skopje');
SELECT add_timezone ('Europe/Sofia');
SELECT add_timezone ('Europe/Stockholm');
SELECT add_timezone ('Europe/Tallinn');
SELECT add_timezone ('Europe/Tirane');
SELECT add_timezone ('Europe/Uzhgorod');
SELECT add_timezone ('Europe/Vaduz');
SELECT add_timezone ('Europe/Vatican');
SELECT add_timezone ('Europe/Vienna');
SELECT add_timezone ('Europe/Vilnius');
SELECT add_timezone ('Europe/Volgograd');
SELECT add_timezone ('Europe/Warsaw');
SELECT add_timezone ('Europe/Zagreb');
SELECT add_timezone ('Europe/Zaporozhye');
SELECT add_timezone ('Europe/Zurich');
SELECT add_timezone ('Indian/Antananarivo');
SELECT add_timezone ('Indian/Chagos');
SELECT add_timezone ('Indian/Christmas');
SELECT add_timezone ('Indian/Cocos');
SELECT add_timezone ('Indian/Comoro');
SELECT add_timezone ('Indian/Kerguelen');
SELECT add_timezone ('Indian/Mahe');
SELECT add_timezone ('Indian/Maldives');
SELECT add_timezone ('Indian/Mauritius');
SELECT add_timezone ('Indian/Mayotte');
SELECT add_timezone ('Indian/Reunion');
SELECT add_timezone ('Pacific/Apia');
SELECT add_timezone ('Pacific/Auckland');
SELECT add_timezone ('Pacific/Chatham');
SELECT add_timezone ('Pacific/Easter');
SELECT add_timezone ('Pacific/Efate');
SELECT add_timezone ('Pacific/Enderbury');
SELECT add_timezone ('Pacific/Fakaofo');
SELECT add_timezone ('Pacific/Fiji');
SELECT add_timezone ('Pacific/Funafuti');
SELECT add_timezone ('Pacific/Galapagos');
SELECT add_timezone ('Pacific/Gambier');
SELECT add_timezone ('Pacific/Guadalcanal');
SELECT add_timezone ('Pacific/Guam');
SELECT add_timezone ('Pacific/Honolulu');
SELECT add_timezone ('Pacific/Johnston');
SELECT add_timezone ('Pacific/Kiritimati');
SELECT add_timezone ('Pacific/Kosrae');
SELECT add_timezone ('Pacific/Kwajalein');
SELECT add_timezone ('Pacific/Majuro');
SELECT add_timezone ('Pacific/Marquesas');
SELECT add_timezone ('Pacific/Midway');
SELECT add_timezone ('Pacific/Nauru');
SELECT add_timezone ('Pacific/Niue');
SELECT add_timezone ('Pacific/Norfolk');
SELECT add_timezone ('Pacific/Noumea');
SELECT add_timezone ('Pacific/Pago_Pago');
SELECT add_timezone ('Pacific/Palau');
SELECT add_timezone ('Pacific/Pitcairn');
SELECT add_timezone ('Pacific/Ponape');
SELECT add_timezone ('Pacific/Port_Moresby');
SELECT add_timezone ('Pacific/Rarotonga');
SELECT add_timezone ('Pacific/Saipan');
SELECT add_timezone ('Pacific/Tahiti');
SELECT add_timezone ('Pacific/Tarawa');
SELECT add_timezone ('Pacific/Tongatapu');
SELECT add_timezone ('Pacific/Truk');
SELECT add_timezone ('Pacific/Wake');
SELECT add_timezone ('Pacific/Wallis');
*/

DROP FUNCTION add_timezone (text);
