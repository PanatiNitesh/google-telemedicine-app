import 'dart:async';
import 'dart:io' show File;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/app/pages/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/app/pages/notificationservice.dart'; 
import 'health_tips.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _consentGiven = false;
  bool isLoading = false;
  final AuthService authService = AuthService();
  
  var _firstNameController = TextEditingController();
  var _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _govMedicalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedCountry;
  String? _selectedState;
  File? _profileImageFile;
  Uint8List? _profileImageBytes;
  String? _completePhoneNumber;

final String _backendUrl = dotenv.env['BASE_URL'] ?? 'https://backend-solution-challenge-dqfbfad9dmd2cua0.canadacentral-01.azurewebsites.net/api';

  final ImagePicker _picker = ImagePicker();

  final List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo, Democratic Republic of the',
    'Congo, Republic of the',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'East Timor',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Korea, North',
    'Korea, South',
    'Kosovo',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];

  final Map<String, List<String>> countryStates = {
    'Afghanistan': [
      'Badakhshan',
      'Badghis',
      'Baghlan',
      'Balkh',
      'Bamyan',
      'Daykundi',
      'Farah',
      'Faryab',
      'Ghazni',
      'Ghor',
      'Helmand',
      'Herat',
      'Jowzjan',
      'Kabul',
      'Kandahar',
      'Kapisa',
      'Khost',
      'Kunar',
      'Kunduz',
      'Laghman',
      'Logar',
      'Nangarhar',
      'Nimroz',
      'Nuristan',
      'Paktia',
      'Paktika',
      'Panjshir',
      'Parwan',
      'Samangan',
      'Sar-e Pol',
      'Takhar',
      'Urozgan',
      'Zabul',
    ],
    'Albania': [
      'Berat',
      'Dibër',
      'Durrës',
      'Elbasan',
      'Fier',
      'Gjirokastër',
      'Korçë',
      'Kukës',
      'Lezhë',
      'Shkodër',
      'Tirana',
      'Vlorë',
    ],
    'Algeria': [
      'Adrar',
      'Aïn Defla',
      'Aïn Témouchent',
      'Alger',
      'Annaba',
      'Batna',
      'Béchar',
      'Béjaïa',
      'Biskra',
      'Blida',
      'Bordj Bou Arréridj',
      'Bouira',
      'Boumerdès',
      'Chlef',
      'Constantine',
      'Djelfa',
      'El Bayadh',
      'El Oued',
      'El Tarf',
      'Ghardaïa',
      'Guelma',
      'Illizi',
      'Jijel',
      'Khenchela',
      'Laghouat',
      'Mascara',
      'Médéa',
      'Mila',
      'Mostaganem',
      'Msila',
      'Naâma',
      'Oran',
      'Ouargla',
      'Oum El Bouaghi',
      'Relizane',
      'Saïda',
      'Sétif',
      'Sidi Bel Abbès',
      'Skikda',
      'Souk Ahras',
      'Tamanghasset',
      'Tébessa',
      'Tiaret',
      'Tindouf',
      'Tipaza',
      'Tissemsilt',
      'Tizi Ouzou',
      'Tlemcen',
    ],
    'Argentina': [
      'Buenos Aires',
      'Catamarca',
      'Chaco',
      'Chubut',
      'Córdoba',
      'Corrientes',
      'Entre Ríos',
      'Formosa',
      'Jujuy',
      'La Pampa',
      'La Rioja',
      'Mendoza',
      'Misiones',
      'Neuquén',
      'Río Negro',
      'Salta',
      'San Juan',
      'San Luis',
      'Santa Cruz',
      'Santa Fe',
      'Santiago del Estero',
      'Tierra del Fuego',
      'Tucumán',
    ],
    'Australia': [
      'Australian Capital Territory',
      'New South Wales',
      'Northern Territory',
      'Queensland',
      'South Australia',
      'Tasmania',
      'Victoria',
      'Western Australia',
    ],
    'Austria': [
      'Burgenland',
      'Carinthia',
      'Lower Austria',
      'Salzburg',
      'Styria',
      'Tyrol',
      'Upper Austria',
      'Vienna',
      'Vorarlberg',
    ],
    'Bangladesh': [
      'Barisal',
      'Chittagong',
      'Dhaka',
      'Khulna',
      'Rajshahi',
      'Rangpur',
      'Sylhet',
    ],
    'Belarus': ['Brest', 'Gomel', 'Grodno', 'Minsk', 'Mogilev', 'Vitebsk'],
    'Belgium': [
      'Antwerp',
      'Brussels',
      'East Flanders',
      'Flemish Brabant',
      'Hainaut',
      'Liège',
      'Limburg',
      'Luxembourg',
      'Namur',
      'Walloon Brabant',
      'West Flanders',
    ],
    'Bolivia': [
      'Beni',
      'Chuquisaca',
      'Cochabamba',
      'La Paz',
      'Oruro',
      'Pando',
      'Potosí',
      'Santa Cruz',
      'Tarija',
    ],
    'Bosnia and Herzegovina': [
      'Federation of Bosnia and Herzegovina',
      'Republika Srpska',
      'Brčko District',
    ],
    'Brazil': [
      'Acre',
      'Alagoas',
      'Amapá',
      'Amazonas',
      'Bahia',
      'Ceará',
      'Espírito Santo',
      'Goiás',
      'Maranhão',
      'Mato Grosso',
      'Mato Grosso do Sul',
      'Minas Gerais',
      'Pará',
      'Paraíba',
      'Paraná',
      'Pernambuco',
      'Piauí',
      'Rio de Janeiro',
      'Rio Grande do Norte',
      'Rio Grande do Sul',
      'Rondônia',
      'Roraima',
      'Santa Catarina',
      'São Paulo',
      'Sergipe',
      'Tocantins',
    ],
    'Bulgaria': [
      'Blagoevgrad',
      'Burgas',
      'Dobrich',
      'Gabrovo',
      'Haskovo',
      'Kardzhali',
      'Kyustendil',
      'Lovech',
      'Montana',
      'Pazardzhik',
      'Pernik',
      'Pleven',
      'Plovdiv',
      'Razgrad',
      'Ruse',
      'Shumen',
      'Silistra',
      'Sliven',
      'Smolyan',
      'Sofia',
      'Sofia City',
      'Stara Zagora',
      'Targovishte',
      'Varna',
      'Veliko Tarnovo',
      'Vidin',
      'Vratsa',
      'Yambol',
    ],
    'Canada': [
      'Alberta',
      'British Columbia',
      'Manitoba',
      'New Brunswick',
      'Newfoundland and Labrador',
      'Nova Scotia',
      'Ontario',
      'Prince Edward Island',
      'Quebec',
      'Saskatchewan',
    ],
    'Chile': [
      'Aisén',
      'Antofagasta',
      'Araucanía',
      'Arica and Parinacota',
      'Atacama',
      'Bío Bío',
      'Coquimbo',
      'La Araucanía',
      'Los Lagos',
      'Los Ríos',
      'Magallanes',
      'Maule',
      'Ñuble',
      'O’Higgins',
      'Santiago Metropolitan',
      'Tarapacá',
      'Valparaíso',
    ],
    'China': [
      'Anhui',
      'Beijing',
      'Chongqing',
      'Fujian',
      'Gansu',
      'Guangdong',
      'Guangxi',
      'Guizhou',
      'Hainan',
      'Hebei',
      'Heilongjiang',
      'Henan',
      'Hubei',
      'Hunan',
      'Inner Mongolia',
      'Jiangsu',
      'Jiangxi',
      'Jilin',
      'Liaoning',
      'Ningxia',
      'Qinghai',
      'Shaanxi',
      'Shandong',
      'Shanghai',
      'Shanxi',
      'Sichuan',
      'Tianjin',
      'Tibet',
      'Xinjiang',
      'Yunnan',
      'Zhejiang',
    ],
    'Colombia': [
      'Amazonas',
      'Antioquia',
      'Arauca',
      'Atlántico',
      'Bolívar',
      'Boyacá',
      'Caldas',
      'Caquetá',
      'Casanare',
      'Cauca',
      'Cesar',
      'Chocó',
      'Córdoba',
      'Cundinamarca',
      'Guainía',
      'Guaviare',
      'Huila',
      'La Guajira',
      'Magdalena',
      'Meta',
      'Nariño',
      'Norte de Santander',
      'Putumayo',
      'Quindío',
      'Risaralda',
      'San Andrés and Providencia',
      'Santander',
      'Sucre',
      'Tolima',
      'Valle del Cauca',
      'Vaupés',
      'Vichada',
    ],
    'Croatia': [
      'Bjelovar-Bilogora',
      'Dubrovnik-Neretva',
      'Istria',
      'Karlovac',
      'Koprivnica-Križevci',
      'Lika-Senj',
      'Međimurje',
      'Osijek-Baranja',
      'Požega-Slavonia',
      'Primorje-Gorski Kotar',
      'Sisak-Moslavina',
      'Split-Dalmatia',
      'Šibenik-Knin',
      'Varaždin',
      'Virovitica-Podravina',
      'Vukovar-Srijem',
      'Zadar',
      'Zagreb',
      'Zagreb County',
    ],
    'Czech Republic': [
      'Central Bohemian',
      'Hradec Králové',
      'Karlovy Vary',
      'Liberec',
      'Moravian-Silesian',
      'Olomouc',
      'Pardubice',
      'Plzeň',
      'Prague',
      'South Bohemian',
      'South Moravian',
      'Ústí nad Labem',
      'Vysočina',
      'Zlín',
    ],
    'Denmark': [
      'Capital Region',
      'Central Denmark Region',
      'North Denmark Region',
      'Region of Southern Denmark',
      'Zealand',
    ],
    'Ecuador': [
      'Azuay',
      'Bolívar',
      'Cañar',
      'Carchi',
      'Chimborazo',
      'Cotopaxi',
      'El Oro',
      'Esmeraldas',
      'Guayas',
      'Imbabura',
      'Loja',
      'Los Ríos',
      'Manabí',
      'Morona-Santiago',
      'Napo',
      'Orellana',
      'Pastaza',
      'Pichincha',
      'Santa Elena',
      'Santo Domingo de los Tsáchilas',
      'Sucumbíos',
      'Tungurahua',
      'Zamora-Chinchipe',
    ],
    'Egypt': [
      'Alexandria',
      'Aswan',
      'Asyut',
      'Beheira',
      'Beni Suef',
      'Cairo',
      'Dakahlia',
      'Damietta',
      'Faiyum',
      'Gharbia',
      'Giza',
      'Ismailia',
      'Kafr El Sheikh',
      'Luxor',
      'Matrouh',
      'Minya',
      'Monufia',
      'New Valley',
      'North Sinai',
      'Port Said',
      'Qalyubia',
      'Qena',
      'Red Sea',
      'Sharqia',
      'Sohag',
      'South Sinai',
      'Suez',
    ],
    'Ethiopia': [
      'Afar',
      'Amhara',
      'Benishangul-Gumuz',
      'Dire Dawa',
      'Gambela',
      'Harari',
      'Oromia',
      'Sidama',
      'Somali',
      'Southern Nations, Nationalities, and Peoples\' Region',
      'Tigray',
    ],
    'Finland': [
      'Åland',
      'Central Finland',
      'Finland Proper',
      'Kainuu',
      'Lapland',
      'North Karelia',
      'North Ostrobothnia',
      'North Savo',
      'Ostrobothnia',
      'Päijänne Tavastia',
      'Pirkanmaa',
      'Satakunta',
      'South Karelia',
      'South Ostrobothnia',
      'South Savo',
      'Uusimaa',
    ],
    'France': [
      'Auvergne-Rhône-Alpes',
      'Bourgogne-Franche-Comté',
      'Brittany',
      'Centre-Val de Loire',
      'Corsica',
      'Grand Est',
      'Hauts-de-France',
      'Île-de-France',
      'Normandy',
      'Nouvelle-Aquitaine',
      'Occitanie',
      'Pays de la Loire',
      'Provence-Alpes-Côte d\'Azur',
    ],
    'Germany': [
      'Baden-Württemberg',
      'Bavaria',
      'Berlin',
      'Brandenburg',
      'Bremen',
      'Hamburg',
      'Hesse',
      'Lower Saxony',
      'Mecklenburg-Vorpommern',
      'North Rhine-Westphalia',
      'Rhineland-Palatinate',
      'Saarland',
      'Saxony',
      'Saxony-Anhalt',
      'Schleswig-Holstein',
      'Thuringia',
    ],
    'Greece': [
      'Attica',
      'Central Greece',
      'Central Macedonia',
      'Crete',
      'East Macedonia and Thrace',
      'Epirus',
      'Ionian Islands',
      'North Aegean',
      'Peloponnese',
      'South Aegean',
      'Thessaly',
      'West Greece',
      'West Macedonia',
    ],
    'Hungary': [
      'Bács-Kiskun',
      'Baranya',
      'Békés',
      'Borsod-Abaúj-Zemplén',
      'Csongrád-Csanád',
      'Fejér',
      'Győr-Moson-Sopron',
      'Hajdú-Bihar',
      'Heves',
      'Jász-Nagykun-Szolnok',
      'Komárom-Esztergom',
      'Nógrád',
      'Pest',
      'Somogy',
      'Szabolcs-Szatmár-Bereg',
      'Tolna',
      'Vas',
      'Veszprém',
      'Zala',
    ],
    'India': [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
    ],
    'Indonesia': [
      'Aceh',
      'Bali',
      'Bangka Belitung Islands',
      'Banten',
      'Bengkulu',
      'Central Java',
      'Central Kalimantan',
      'Central Sulawesi',
      'East Java',
      'East Kalimantan',
      'East Nusa Tenggara',
      'Gorontalo',
      'Jakarta',
      'Jambi',
      'Lampung',
      'Maluku',
      'North Kalimantan',
      'North Maluku',
      'North Sulawesi',
      'North Sumatra',
      'Papua',
      'Riau',
      'South Kalimantan',
      'South Sulawesi',
      'South Sumatra',
      'Southeast Sulawesi',
      'West Java',
      'West Kalimantan',
      'West Nusa Tenggara',
      'West Papua',
      'West Sulawesi',
      'West Sumatra',
      'Yogyakarta',
    ],
    'Iran': [
      'Alborz',
      'Ardabil',
      'Bushehr',
      'Chahar Mahaal and Bakhtiari',
      'East Azerbaijan',
      'Fars',
      'Gilan',
      'Golestan',
      'Hamadan',
      'Hormozgan',
      'Ilam',
      'Isfahan',
      'Kerman',
      'Kermanshah',
      'Khuzestan',
      'Kohgiluyeh and Boyer-Ahmad',
      'Kurdistan',
      'Lorestan',
      'Markazi',
      'Mazandaran',
      'North Khorasan',
      'Qazvin',
      'Qom',
      'Razavi Khorasan',
      'Semnan',
      'Sistan and Baluchestan',
      'South Khorasan',
      'Tehran',
      'West Azerbaijan',
      'Yazd',
      'Zanjan',
    ],
    'Iraq': [
      'Anbar',
      'Babil',
      'Baghdad',
      'Basra',
      'Dhi Qar',
      'Diyala',
      'Dohuk',
      'Erbil',
      'Karbala',
      'Kirkuk',
      'Maysan',
      'Muthanna',
      'Najaf',
      'Nineveh',
      'Saladin',
      'Sulaymaniyah',
      'Wasit',
    ],
    'Italy': [
      'Abruzzo',
      'Aosta Valley',
      'Apulia',
      'Basilicata',
      'Calabria',
      'Campania',
      'Emilia-Romagna',
      'Friuli-Venezia Giulia',
      'Lazio',
      'Liguria',
      'Lombardy',
      'Marche',
      'Molise',
      'Piedmont',
      'Sardinia',
      'Sicily',
      'Trentino-South Tyrol',
      'Tuscany',
      'Umbria',
      'Veneto',
    ],
    'Japan': [
      'Aichi',
      'Akita',
      'Aomori',
      'Chiba',
      'Ehime',
      'Fukui',
      'Fukuoka',
      'Fukushima',
      'Gifu',
      'Gunma',
      'Hiroshima',
      'Hokkaido',
      'Hyogo',
      'Ibaraki',
      'Ishikawa',
      'Iwate',
      'Kagawa',
      'Kagoshima',
      'Kanagawa',
      'Kochi',
      'Kumamoto',
      'Kyoto',
      'Mie',
      'Miyagi',
      'Miyazaki',
      'Nagano',
      'Nagasaki',
      'Nara',
      'Niigata',
      'Oita',
      'Okayama',
      'Okinawa',
      'Osaka',
      'Saga',
      'Saitama',
      'Shiga',
      'Shimane',
      'Shizuoka',
      'Tochigi',
      'Tokushima',
      'Tokyo',
      'Tottori',
      'Toyama',
      'Wakayama',
      'Yamagata',
      'Yamaguchi',
      'Yamanashi',
    ],
    'Kenya': [
      'Baringo',
      'Bomet',
      'Bungoma',
      'Busia',
      'Elgeyo-Marakwet',
      'Embu',
      'Garissa',
      'Homa Bay',
      'Isiolo',
      'Kajiado',
      'Kakamega',
      'Kericho',
      'Kiambu',
      'Kilifi',
      'Kirinyaga',
      'Kisii',
      'Kisumu',
      'Kitui',
      'Kwale',
      'Laikipia',
      'Lamu',
      'Machakos',
      'Makueni',
      'Mandera',
      'Marsabit',
      'Meru',
      'Migori',
      'Mombasa',
      'Murang\'a',
      'Nairobi',
      'Nakuru',
      'Nandi',
      'Narok',
      'Nyamira',
      'Nyandarua',
      'Nyeri',
      'Samburu',
      'Siaya',
      'Taita-Taveta',
      'Tana River',
      'Tharaka-Nithi',
      'Trans Nzoia',
      'Turkana',
      'Uasin Gishu',
      'Vihiga',
      'Wajir',
      'West Pokot',
    ],
    'Malaysia': [
      'Johor',
      'Kedah',
      'Kelantan',
      'Malacca',
      'Negeri Sembilan',
      'Pahang',
      'Penang',
      'Perak',
      'Perlis',
      'Sabah',
      'Sarawak',
      'Selangor',
      'Terengganu',
    ],
    'Mexico': [
      'Aguascalientes',
      'Baja California',
      'Baja California Sur',
      'Campeche',
      'Chiapas',
      'Chihuahua',
      'Coahuila',
      'Colima',
      'Durango',
      'Guanajuato',
      'Guerrero',
      'Hidalgo',
      'Jalisco',
      'Mexico City',
      'Michoacán',
      'Morelos',
      'Nayarit',
      'Nuevo León',
      'Oaxaca',
      'Puebla',
      'Querétaro',
      'Quintana Roo',
      'San Luis Potosí',
      'Sinaloa',
      'Sonora',
      'Tabasco',
      'Tamaulipas',
      'Tlaxcala',
      'Veracruz',
      'Yucatán',
      'Zacatecas',
    ],
    'Morocco': [
      'Béni Mellal-Khénifra',
      'Casablanca-Settat',
      'Dakhla-Oued Ed-Dahab',
      'Drâa-Tafilalet',
      'Fès-Meknès',
      'Guelmim-Oued Noun',
      'Laâyoune-Sakia El Hamra',
      'Marrakech-Safi',
      'Oriental',
      'Rabat-Salé-Kénitra',
      'Souss-Massa',
      'Tangier-Tétouan-Al Hoceïma',
    ],
    'Myanmar': [
      'Ayeyarwady',
      'Bago',
      'Chin',
      'Kachin',
      'Kayah',
      'Kayin',
      'Magway',
      'Mandalay',
      'Mon',
      'Naypyidaw',
      'Rakhine',
      'Sagaing',
      'Shan',
      'Tanintharyi',
      'Yangon',
    ],
    'Nepal': [
      'Bagmati',
      'Gandaki',
      'Karnali',
      'Koshi',
      'Lumbini',
      'Madhesh',
      'Sudurpashchim',
    ],
    'Netherlands': [
      'Drenthe',
      'Flevoland',
      'Friesland',
      'Gelderland',
      'Groningen',
      'Limburg',
      'North Brabant',
      'North Holland',
      'Overijssel',
      'South Holland',
      'Utrecht',
      'Zeeland',
    ],
    'New Zealand': [
      'Auckland',
      'Bay of Plenty',
      'Canterbury',
      'Hawke\'s Bay',
      'Manawatu-Whanganui',
      'Marlborough',
      'Nelson',
      'Northland',
      'Otago',
      'Southland',
      'Taranaki',
      'Tasman',
      'Waikato',
      'Wellington',
      'West Coast',
    ],
    'Nigeria': [
      'Abia',
      'Adamawa',
      'Akwa Ibom',
      'Anambra',
      'Bauchi',
      'Bayelsa',
      'Benue',
      'Borno',
      'Cross River',
      'Delta',
      'Ebonyi',
      'Edo',
      'Ekiti',
      'Enugu',
      'Gombe',
      'Imo',
      'Jigawa',
      'Kaduna',
      'Kano',
      'Katsina',
      'Kebbi',
      'Kogi',
      'Kwara',
      'Lagos',
      'Nasarawa',
      'Niger',
      'Ogun',
      'Ondo',
      'Osun',
      'Oyo',
      'Plateau',
      'Rivers',
      'Sokoto',
      'Taraba',
      'Yobe',
      'Zamfara',
    ],
    'Pakistan': [
      'Balochistan',
      'Khyber Pakhtunkhwa',
      'Punjab',
      'Sindh',
      'Gilgit-Baltistan',
      'Azad Jammu and Kashmir',
    ],
    'Peru': [
      'Amazonas',
      'Áncash',
      'Apurímac',
      'Arequipa',
      'Ayacucho',
      'Cajamarca',
      'Callao',
      'Cusco',
      'Huancavelica',
      'Huanuco',
      'Ica',
      'Junín',
      'La Libertad',
      'Lambayeque',
      'Lima',
      'Loreto',
      'Madre de Dios',
      'Moquegua',
      'Pasco',
      'Piura',
      'Puno',
      'San Martín',
      'Tacna',
      'Tumbes',
      'Ucayali',
    ],
    'Philippines': [
      'Abra',
      'Agusan del Norte',
      'Agusan del Sur',
      'Aklan',
      'Albay',
      'Antique',
      'Apayao',
      'Aurora',
      'Basilan',
      'Bataan',
      'Batanes',
      'Batangas',
      'Benguet',
      'Biliran',
      'Bohol',
      'Bukidnon',
      'Bulacan',
      'Cagayan',
      'Camarines Norte',
      'Camarines Sur',
      'Camiguin',
      'Capiz',
      'Catanduanes',
      'Cavite',
      'Cebu',
      'Cotabato',
      'Davao de Oro',
      'Davao del Norte',
      'Davao del Sur',
      'Davao Occidental',
      'Davao Oriental',
      'Dinagat Islands',
      'Eastern Samar',
      'Guimaras',
      'Ifugao',
      'Ilocos Norte',
      'Ilocos Sur',
      'Iloilo',
      'Isabela',
      'Kalinga',
      'La Union',
      'Laguna',
      'Lanao del Norte',
      'Lanao del Sur',
      'Leyte',
      'Maguindanao',
      'Marinduque',
      'Masbate',
      'Misamis Occidental',
      'Misamis Oriental',
      'Mountain Province',
      'Negros Occidental',
      'Negros Oriental',
      'Northern Samar',
      'Nueva Ecija',
      'Nueva Vizcaya',
      'Occidental Mindoro',
      'Oriental Mindoro',
      'Palawan',
      'Pampanga',
      'Pangasinan',
      'Quezon',
      'Quirino',
      'Rizal',
      'Romblon',
      'Samar',
      'Sarangani',
      'Siquijor',
      'Sorsogon',
      'South Cotabato',
      'Southern Leyte',
      'Sultan Kudarat',
      'Sulu',
      'Surigao del Norte',
      'Surigao del Sur',
      'Tarlac',
      'Tawi-Tawi',
      'Zambales',
      'Zamboanga del Norte',
      'Zamboanga del Sur',
      'Zamboanga Sibugay',
    ],
    'Poland': [
      'Greater Poland',
      'Kuyavian-Pomeranian',
      'Lesser Poland',
      'Lodz',
      'Lower Silesian',
      'Lublin',
      'Lubusz',
      'Masovian',
      'Opole',
      'Podlaskie',
      'Pomeranian',
      'Silesian',
      'Subcarpathian',
      'Świętokrzyskie',
      'Warmian-Masurian',
      'West Pomeranian',
    ],
    'Romania': [
      'Alba',
      'Arad',
      'Argeș',
      'Bacău',
      'Bihor',
      'Bistrița-Năsăud',
      'Botoșani',
      'Brașov',
      'Brăila',
      'București',
      'Buzău',
      'Călărași',
      'Caraș-Severin',
      'Cluj',
      'Constanța',
      'Covasna',
      'Dâmbovița',
      'Dolj',
      'Galați',
      'Giurgiu',
      'Gorj',
      'Harghita',
      'Hunedoara',
      'Ialomița',
      'Iași',
      'Ilfov',
      'Maramureș',
      'Mehedinți',
      'Mureș',
      'Neamț',
      'Olt',
      'Prahova',
      'Satu Mare',
      'Sălaj',
      'Sibiu',
      'Suceava',
      'Teleorman',
      'Timiș',
      'Tulcea',
      'Vâlcea',
      'Vaslui',
      'Vrancea',
    ],
    'Russia': [
      'Adygea',
      'Altai Republic',
      'Bashkortostan',
      'Buryatia',
      'Chechnya',
      'Chuvashia',
      'Dagestan',
      'Ingushetia',
      'Kabardino-Balkaria',
      'Kalmykia',
      'Karachay-Cherkessia',
      'Karelia',
      'Khakassia',
      'Komi',
      'Mari El',
      'Mordovia',
      'North Ossetia-Alania',
      'Sakha',
      'Tatarstan',
      'Tuva',
      'Udmurtia',
    ],
    'South Africa': [
      'Eastern Cape',
      'Free State',
      'Gauteng',
      'KwaZulu-Natal',
      'Limpopo',
      'Mpumalanga',
      'North West',
      'Northern Cape',
      'Western Cape',
    ],
    'Spain': [
      'Andalusia',
      'Aragon',
      'Asturias',
      'Balearic Islands',
      'Basque Country',
      'Canary Islands',
      'Cantabria',
      'Castile and León',
      'Castile-La Mancha',
      'Catalonia',
      'Community of Madrid',
      'Extremadura',
      'Galicia',
      'La Rioja',
      'Navarre',
      'Region of Murcia',
      'Valencian Community',
    ],
    'Sudan': [
      'Blue Nile',
      'Central Darfur',
      'East Darfur',
      'Gedaref',
      'Kassala',
      'Khartoum',
      'North Darfur',
      'North Kordofan',
      'Northern',
      'Red Sea',
      'River Nile',
      'Sennar',
      'South Darfur',
      'South Kordofan',
      'West Darfur',
      'West Kordofan',
    ],
    'Sweden': [
      'Blekinge',
      'Dalarna',
      'Gävleborg',
      'Gotland',
      'Halland',
      'Jämtland',
      'Jönköping',
      'Kalmar',
      'Kronoberg',
      'Norrbotten',
      'Örebro',
      'Östergötland',
      'Skåne',
      'Södermanland',
      'Stockholm',
      'Uppsala',
      'Värmland',
      'Västerbotten',
      'Västernorrland',
      'Västmanland',
      'Västra Götaland',
    ],
    'Switzerland': [
      'Aargau',
      'Appenzell Ausserrhoden',
      'Appenzell Innerrhoden',
      'Basel-Landschaft',
      'Basel-Stadt',
      'Bern',
      'Fribourg',
      'Geneva',
      'Glarus',
      'Graubünden',
      'Jura',
      'Lucerne',
      'Neuchâtel',
      'Nidwalden',
      'Obwalden',
      'Schaffhausen',
      'Schwyz',
      'Solothurn',
      'St. Gallen',
      'Thurgau',
      'Ticino',
      'Uri',
      'Vaud',
      'Valais',
      'Zug',
      'Zurich',
    ],
    'Thailand': [
      'Amnat Charoen',
      'Ang Thong',
      'Bueng Kan',
      'Buri Ram',
      'Chachoengsao',
      'Chai Nat',
      'Chaiyaphum',
      'Chanthaburi',
      'Chiang Mai',
      'Chiang Rai',
      'Chon Buri',
      'Chumphon',
      'Kalasin',
      'Kamphaeng Phet',
      'Kanchanaburi',
      'Khon Kaen',
      'Krabi',
      'Lampang',
      'Lamphun',
      'Loei',
      'Lop Buri',
      'Mae Hong Son',
      'Maha Sarakham',
      'Mukdahan',
      'Nakhon Pathom',
      'Nakhon Phanom',
      'Nakhon Ratchasima',
      'Nakhon Sawan',
      'Nakhon Si Thammarat',
      'Nan',
      'Narathiwat',
      'Nong Bua Lamphu',
      'Nong Khai',
      'Nonthaburi',
      'Pathum Thani',
      'Pattani',
      'Phang Nga',
      'Phatthalung',
      'Phayao',
      'Phetchabun',
      'Phetchaburi',
      'Phichit',
      'Phitsanulok',
      'Phrae',
      'Phuket',
      'Prachin Buri',
      'Prachuap Khiri Khan',
      'Ranong',
      'Ratchaburi',
      'Rayong',
      'Roi Et',
      'Sa Kaeo',
      'Sakon Nakhon',
      'Samut Prakan',
      'Samut Sakhon',
      'Samut Songkhram',
      'Saraburi',
      'Satun',
      'Sing Buri',
      'Sisaket',
      'Songkhla',
      'Sukhothai',
      'Suphan Buri',
      'Surat Thani',
      'Surin',
      'Tak',
      'Trang',
      'Trat',
      'Ubon Ratchathani',
      'Udon Thani',
      'Uthai Thani',
      'Uttaradit',
      'Yala',
      'Yasothon',
    ],
    'Turkey': [
      'Adana',
      'Adıyaman',
      'Afyonkarahisar',
      'Ağrı',
      'Aksaray',
      'Amasya',
      'Ankara',
      'Antalya',
      'Ardahan',
      'Artvin',
      'Aydın',
      'Balıkesir',
      'Bartın',
      'Batman',
      'Bayburt',
      'Bilecik',
      'Bingöl',
      'Bitlis',
      'Bolu',
      'Burdur',
      'Bursa',
      'Çanakkale',
      'Çankırı',
      'Çorum',
      'Denizli',
      'Diyarbakır',
      'Düzce',
      'Edirne',
      'Elazığ',
      'Erzincan',
      'Erzurum',
      'Eskişehir',
      'Gaziantep',
      'Giresun',
      'Gümüşhane',
      'Hakkari',
      'Hatay',
      'Iğdır',
      'Isparta',
      'Istanbul',
      'Izmir',
      'Kahramanmaraş',
      'Karabük',
      'Karaman',
      'Kars',
      'Kastamonu',
      'Kayseri',
      'Kilis',
      'Kırıkkale',
      'Kırklareli',
      'Kırşehir',
      'Kocaeli',
      'Konya',
      'Kütahya',
      'Malatya',
      'Manisa',
      'Mardin',
      'Mersin',
      'Muğla',
      'Muş',
      'Nevşehir',
      'Niğde',
      'Ordu',
      'Osmaniye',
      'Rize',
      'Sakarya',
      'Samsun',
      'Şanlıurfa',
      'Siirt',
      'Sinop',
      'Sivas',
      'Şırnak',
      'Tekirdağ',
      'Tokat',
      'Trabzon',
      'Tunceli',
      'Uşak',
      'Van',
      'Yalova',
      'Yozgat',
      'Zonguldak',
    ],
    'Ukraine': [
      'Cherkasy',
      'Chernihiv',
      'Chernivtsi',
      'Dnipropetrovsk',
      'Donetsk',
      'Ivano-Frankivsk',
      'Kharkiv',
      'Kherson',
      'Khmelnytskyi',
      'Kiev',
      'Kirovohrad',
      'Luhansk',
      'Lviv',
      'Mykolaiv',
      'Odessa',
      'Poltava',
      'Rivne',
      'Sumy',
      'Ternopil',
      'Vinnytsia',
      'Volyn',
      'Zakarpattia',
      'Zaporizhzhia',
      'Zhytomyr',
    ],
    'United Kingdom': ['England', 'Northern Ireland', 'Scotland', 'Wales'],
    'United States': [
      'Alabama',
      'Alaska',
      'Arizona',
      'Arkansas',
      'California',
      'Colorado',
      'Connecticut',
      'Delaware',
      'Florida',
      'Georgia',
      'Hawaii',
      'Idaho',
      'Illinois',
      'Indiana',
      'Iowa',
      'Kansas',
      'Kentucky',
      'Louisiana',
      'Maine',
      'Maryland',
      'Massachusetts',
      'Michigan',
      'Minnesota',
      'Mississippi',
      'Missouri',
      'Montana',
      'Nebraska',
      'Nevada',
      'New Hampshire',
      'New Jersey',
      'New Mexico',
      'New York',
      'North Carolina',
      'North Dakota',
      'Ohio',
      'Oklahoma',
      'Oregon',
      'Pennsylvania',
      'Rhode Island',
      'South Carolina',
      'South Dakota',
      'Tennessee',
      'Texas',
      'Utah',
      'Vermont',
      'Virginia',
      'Washington',
      'West Virginia',
      'Wisconsin',
      'Wyoming',
    ],
    'Venezuela': [
      'Amazonas',
      'Anzoátegui',
      'Apure',
      'Aragua',
      'Barinas',
      'Bolívar',
      'Carabobo',
      'Cojedes',
      'Delta Amacuro',
      'Falcón',
      'Guárico',
      'Lara',
      'Mérida',
      'Miranda',
      'Monagas',
      'Nueva Esparta',
      'Portuguesa',
      'Sucre',
      'Táchira',
      'Trujillo',
      'Yaracuy',
      'Zulia',
    ],
    'Vietnam': [
      'An Giang',
      'Bà Rịa-Vũng Tàu',
      'Bắc Giang',
      'Bắc Kạn',
      'Bạc Liêu',
      'Bắc Ninh',
      'Bến Tre',
      'Bình Định',
      'Bình Dương',
      'Bình Phước',
      'Bình Thuận',
      'Cà Mau',
      'Cao Bằng',
      'Đắk Lắk',
      'Đắk Nông',
      'Điện Biên',
      'Đồng Nai',
      'Đồng Tháp',
      'Gia Lai',
      'Hà Giang',
      'Hà Nam',
      'Hà Tĩnh',
      'Hải Dương',
      'Hải Phòng',
      'Hậu Giang',
      'Hòa Bình',
      'Hưng Yên',
      'Khánh Hòa',
      'Kiên Giang',
      'Kon Tum',
      'Lai Châu',
      'Lâm Đồng',
      'Lạng Sơn',
      'Lào Cai',
      'Long An',
      'Nam Định',
      'Nghệ An',
      'Ninh Bình',
      'Ninh Thuận',
      'Phú Thọ',
      'Phú Yên',
      'Quảng Bình',
      'Quảng Nam',
      'Quảng Ngãi',
      'Quảng Ninh',
      'Quảng Trị',
      'Sóc Trăng',
      'Sơn La',
      'Tây Ninh',
      'Thái Bình',
      'Thái Nguyên',
      'Thanh Hóa',
      'Thừa Thiên Huế',
      'Tiền Giang',
      'Trà Vinh',
      'Tuyên Quang',
      'Vĩnh Long',
      'Vĩnh Phúc',
      'Yên Bái',
    ],
    'Andorra': [],
    'Antigua and Barbuda': [],
    'Bahamas': [],
    'Bahrain': [],
    'Barbados': [],
    'Belize': [],
    'Bhutan': [],
    'Brunei': [],
    'Comoros': [],
    'Cyprus': [],
    'Djibouti': [],
    'Dominica': [],
    'East Timor': [],
    'El Salvador': [],
    'Equatorial Guinea': [],
    'Eritrea': [],
    'Estonia': [],
    'Eswatini': [],
    'Fiji': [],
    'Gabon': [],
    'Gambia': [],
    'Grenada': [],
    'Guinea': [],
    'Guinea-Bissau': [],
    'Guyana': [],
    'Haiti': [],
    'Iceland': [],
    'Ireland': [],
    'Israel': [],
    'Jamaica': [],
    'Jordan': [],
    'Kiribati': [],
    'Korea, North': [],
    'Korea, South': [],
    'Kosovo': [],
    'Kuwait': [],
    'Kyrgyzstan': [],
    'Laos': [],
    'Latvia': [],
    'Lebanon': [],
    'Lesotho': [],
    'Liberia': [],
    'Liechtenstein': [],
    'Lithuania': [],
    'Luxembourg': [],
    'Malawi': [],
    'Maldives': [],
    'Malta': [],
    'Marshall Islands': [],
    'Mauritania': [],
    'Mauritius': [],
    'Micronesia': [],
    'Moldova': [],
    'Monaco': [],
    'Montenegro': [],
    'Nauru': [],
    'Nicaragua': [],
    'Niger': [],
    'North Macedonia': [],
    'Norway': [],
    'Oman': [],
    'Palau': [],
    'Panama': [],
    'Qatar': [],
    'Saint Kitts and Nevis': [],
    'Saint Lucia': [],
    'Saint Vincent and the Grenadines': [],
    'Samoa': [],
    'San Marino': [],
    'Sao Tome and Principe': [],
    'Saudi Arabia': [],
    'Senegal': [],
    'Seychelles': [],
    'Sierra Leone': [],
    'Singapore': [],
    'Slovakia': [],
    'Slovenia': [],
    'Solomon Islands': [],
    'Somalia': [],
    'South Sudan': [],
    'Suriname': [],
    'Togo': [],
    'Tonga': [],
    'Trinidad and Tobago': [],
    'Tunisia': [],
    'Turkmenistan': [],
    'Tuvalu': [],
    'United Arab Emirates': [],
    'Uruguay': [],
    'Uzbekistan': [],
    'Vanuatu': [],
    'Vatican City': [],
    'Yemen': [],
    'Zambia': [],
    'Zimbabwe': [],
  };

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
  _lastNameController = TextEditingController();
    NotificationService().init();  
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _dateOfBirthController.dispose();
    _fullAddressController.dispose();
    _govMedicalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      try {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _profileImageBytes = bytes;
          });
          developer.log(
            'Web image selected, bytes length: ${bytes.length}',
            name: 'RegisterPage',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Image compression not supported on web. Uploading original image.',
                ),
              ),
            );
          }
        } else {
          final String targetPath = '${image.path}_compressed.jpg';
          final compressedImage = await FlutterImageCompress.compressAndGetFile(
            image.path,
            targetPath,
            quality: 85,
            format: CompressFormat.jpeg,
          );

          if (compressedImage != null) {
            setState(() {
              _profileImageFile = File(compressedImage.path);
            });
            developer.log(
              'Compressed file path: ${compressedImage.path}',
              name: 'RegisterPage',
            );
          } else {
            developer.log(
              'Failed to compress image, using original',
              name: 'RegisterPage',
            );
            setState(() {
              _profileImageFile = File(image.path);
            });
          }
        }
      } catch (e) {
        developer.log('Error processing image: $e', name: 'RegisterPage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to process image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _scheduleHealthTipsForTesting() async {
    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final scheduledTime = now.add(
        Duration(seconds: 10, minutes: 1 + (2 * i)),
      );
      await NotificationService().scheduleNotification(
        id: i,
        title: 'Daily Health Tip 🌟',
        body: HealthTips.getRandomTip(),
        scheduledDate: scheduledTime,
      );
    }
  }

Future<void> _register() async {
  if (_formKey.currentState!.validate() && _consentGiven) {
    setState(() {
      isLoading = true;
    });

    try {
      developer.log('Initial _profileImageFile: ${_profileImageFile?.path}, _profileImageBytes: ${_profileImageBytes?.length}', name: 'RegisterPage');

      if (_profileImageFile != null && _profileImageFile!.existsSync() && _profileImageFile!.lengthSync() > 512 * 1024) {
        developer.log('Image is too large (${_profileImageFile!.lengthSync()} bytes), compressing further', name: 'RegisterPage');
        final compressedImage = await FlutterImageCompress.compressWithFile(
          _profileImageFile!.path,
          quality: 50,
          minWidth: 400,
          minHeight: 400,
        );
        if (compressedImage != null) {
          _profileImageBytes = compressedImage;
          _profileImageFile = null; 
          developer.log('Further compressed image size: ${compressedImage.length} bytes', name: 'RegisterPage');
        } else {
          developer.log('Compression failed, keeping original _profileImageFile', name: 'RegisterPage');
        }
      } else {
        developer.log('No compression needed or _profileImageFile is null', name: 'RegisterPage');
      }

      developer.log('After compression - _profileImageFile: ${_profileImageFile?.path}, _profileImageBytes: ${_profileImageBytes?.length}', name: 'RegisterPage');

      var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));

      request.fields['firstName'] = _firstNameController.text;
      request.fields['lastName'] = _lastNameController.text;
      request.fields['gender'] = _genderController.text;
      request.fields['email'] = _emailController.text;
      request.fields['phoneNumber'] = _completePhoneNumber ?? _phoneNumberController.text;
      request.fields['dateOfBirth'] = _dateOfBirthController.text;
      request.fields['address'] = _fullAddressController.text;
      request.fields['country'] = _selectedCountry ?? '';
      request.fields['state'] = _selectedState ?? '';
      request.fields['governmentId'] = _govMedicalIdController.text;
      request.fields['password'] = _passwordController.text;

      if (_profileImageFile != null && _profileImageFile!.existsSync()) {
        developer.log('Adding image to request, file size: ${_profileImageFile!.lengthSync()} bytes', name: 'RegisterPage');
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          _profileImageFile!.path,
          contentType: http_parser.MediaType('image', 'jpeg'),
        ));
      } else if (_profileImageBytes != null) {
        developer.log('Adding web image to request, bytes length: ${_profileImageBytes!.length}', name: 'RegisterPage');
        request.files.add(http.MultipartFile.fromBytes(
          'profileImage',
          _profileImageBytes!,
          contentType: http_parser.MediaType('image', 'jpeg'),
          filename: 'profile.jpg',
        ));
      } else {
        developer.log('No profile image to upload', name: 'RegisterPage');
      }

      developer.log('Sending request to: $_backendUrl', name: 'RegisterPage');
      developer.log('Request fields: ${request.fields}', name: 'RegisterPage');
      developer.log('Request files: ${request.files.map((f) => f.filename).join(', ')}', name: 'RegisterPage');

      var response = await request.send().timeout(const Duration(seconds: 60), onTimeout: () {
        developer.log('Request timed out after 60 seconds', name: 'RegisterPage');
        return http.StreamedResponse(Stream.empty(), 408);
      });

      developer.log('Request sent, awaiting response...', name: 'RegisterPage');
      var responseData = await http.Response.fromStream(response);
      developer.log('Response status: ${response.statusCode}, Body: ${responseData.body}', name: 'RegisterPage');

if (response.statusCode == 201) {
  final jsonResponse = jsonDecode(responseData.body);
  developer.log('Parsed JSON response: $jsonResponse', name: 'RegisterPage');
  if (jsonResponse['success'] == true) {
    final user = jsonResponse['user'];
    final userId = user != null ? user['id']?.toString() ?? '' : ''; 
    final token = jsonResponse['token']?.toString() ?? '';
    final profileImage = user != null ? user['profileImage']?.toString() : null; 
    final firstName = _firstNameController.text; 
    final lastName = _lastNameController.text;   
    final email = _emailController.text;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', email);
    await prefs.setString('userId', userId);
    await prefs.setString('firstName', firstName); 
    await prefs.setString('lastName', lastName); 
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setBool('isLoggedIn', true);

    await prefs.setString('phone', _completePhoneNumber ?? _phoneNumberController.text);
    await prefs.setString('dob', _dateOfBirthController.text);
    await prefs.setString('address', _fullAddressController.text);
    await prefs.setString('id', _govMedicalIdController.text);
    await prefs.setString('gender', _genderController.text);
    developer.log('Before saving profile image - _profileImageFile: ${_profileImageFile?.path}, _profileImageBytes: ${_profileImageBytes?.length}', name: 'RegisterPage');
    String? profileImageToPass; 
    if (_profileImageBytes != null) {
      final profileImageBase64 = base64Encode(_profileImageBytes!);
      final profileImageWithPrefix = 'data:image/jpeg;base64,$profileImageBase64'; 
      await prefs.setString('profileImage', profileImageWithPrefix);
      profileImageToPass = profileImageWithPrefix;
      developer.log('Saved profileImage (from bytes): $profileImageWithPrefix', name: 'RegisterPage');
    } else if (_profileImageFile != null && _profileImageFile!.existsSync()) {
      final bytes = await _profileImageFile!.readAsBytes();
      final profileImageBase64 = base64Encode(bytes);
      final profileImageWithPrefix = 'data:image/jpeg;base64,$profileImageBase64';
      await prefs.setString('profileImage', profileImageWithPrefix);
      profileImageToPass = profileImageWithPrefix;
      developer.log('Saved profileImage (from file): $profileImageWithPrefix', name: 'RegisterPage');
    } else if (profileImage != null && profileImage.isNotEmpty) {
      await prefs.setString('profileImage', profileImage);
      profileImageToPass = profileImage;
      developer.log('Saved profileImage (from backend): $profileImage', name: 'RegisterPage');
    } else {
      await prefs.remove('profileImage');
      profileImageToPass = null;
      developer.log('No profile image to save, removed profileImage key', name: 'RegisterPage');
    }

    developer.log('Saved username: $email', name: 'RegisterPage');
    developer.log('Saved userId: $userId', name: ' 🙂');
    developer.log('Saved firstName: $firstName', name: 'RegisterPage');
    developer.log('Saved lastName: $lastName', name: 'RegisterPage');
    developer.log('Saved auth_token: $token', name: 'RegisterPage');
    developer.log('Saved phone: ${_completePhoneNumber ?? _phoneNumberController.text}', name: 'RegisterPage');
    developer.log('Saved dob: ${_dateOfBirthController.text}', name: 'RegisterPage');
    developer.log('Saved address: ${_fullAddressController.text}', name: 'RegisterPage');
    developer.log('Saved id: ${_govMedicalIdController.text}', name: 'RegisterPage');
    developer.log('Saved gender: ${_genderController.text}', name: 'RegisterPage');
    try {
      await _scheduleHealthTipsForTesting();
    } catch (e) {
      developer.log('Failed to schedule health tips: $e', name: 'RegisterPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful, but failed to schedule notifications: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            fullName: '$firstName $lastName', 
            email: email, 
            profileImage: profileImageToPass, 
          ),
        ),
      );
    }
  } else {
    throw Exception(jsonResponse['message'] ?? 'Registration failed');
  }
} else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(responseData.body);
        throw Exception(jsonResponse['message'] ?? 'Bad request');
      } else if (response.statusCode == 408) {
        throw Exception('Request timed out. Please check your network or server status.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error: $e', name: 'RegisterPage');
      if (mounted) {
        String errorMessage;
        if (e.toString().contains('Request timed out')) {
          errorMessage = 'Request timed out. Please check your network or server status.';
        } else if (e.toString().contains('Email already registered')) {
          errorMessage = 'Email already registered. Please use a different email.';
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and give consent'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: CustomPaint(painter: TrianglePainter()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 200),
                          const Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('First Name', isRequired: true),
                                _buildTextField(
                                  'First Name',
                                  controller: _firstNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'First name is required';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z\s]+$',
                                    ).hasMatch(value)) {
                                      return 'First name should contain only letters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                _buildLabel('Last Name', isRequired: true),
                                _buildTextField(
                                  'Last Name',
                                  controller: _lastNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Last name is required';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z\s]+$',
                                    ).hasMatch(value)) {
                                      return 'Last name should contain only letters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                _buildLabel('Gender', isRequired: true),
                                _buildTextField(
                                  'Gender (e.g., Male/Female/Other)',
                                  controller: _genderController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Gender is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                _buildLabel('Email', isRequired: true),
                                _buildTextField(
                                  'example@gmail.com',
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                _buildLabel('Phone Number', isRequired: true),
                                IntlPhoneField(
                                  controller: _phoneNumberController,
                                  decoration: InputDecoration(
                                    hintText: 'Phone Number',
                                    filled: true,
                                    fillColor: Colors.grey.shade300,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  initialCountryCode: 'US',
                                  onChanged: (phone) {
                                    setState(() {
                                      _completePhoneNumber =
                                          phone.completeNumber;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.number.isEmpty) {
                                      return 'Phone number is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                _buildLabel('Date of Birth', isRequired: true),
                                _buildDateField(),
                                const SizedBox(height: 15),

                                _buildLabel('Full Address', isRequired: true),
                                _buildTextField(
                                  '7th street - medicine road, doctor 82',
                                  controller: _fullAddressController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Address is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel(
                                            'Country',
                                            isRequired: true,
                                          ),
                                          _buildCountryAutocomplete(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel(
                                            'State',
                                            isRequired: true,
                                          ),
                                          _buildStateAutocomplete(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                _buildLabel(
                                  'Government/Medical ID',
                                  isRequired: true,
                                ),
                                _buildTextField(
                                  '9999-8888-7777-6666',
                                  controller: _govMedicalIdController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Government/Medical ID is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                            _profileImageFile != null ||
                                                    _profileImageBytes != null
                                                ? ClipOval(
                                                  child:
                                                      _profileImageFile != null
                                                          ? Image.file(
                                                            _profileImageFile!,
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          )
                                                          : Image.memory(
                                                            _profileImageBytes!,
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                )
                                                : const Icon(
                                                  Icons.person_outline,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: _pickImage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade300,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Upload Image',
                                          style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _buildLabel(
                                  'Create Password',
                                  isRequired: true,
                                ),
                                _buildTextField(
                                  'Password',
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters long';
                                    }
                                    if (!RegExp(
                                      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$',
                                    ).hasMatch(value)) {
                                      return 'Password must contain at least one letter and one number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                Row(
                                  children: [
                                    Checkbox(
                                      value: _consentGiven,
                                      onChanged: (value) {
                                        setState(() {
                                          _consentGiven = value ?? false;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Consent & Agreements',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),

                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(3, (index) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              index == 0
                                                  ? Colors.blue
                                                  : Colors.grey,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Center(
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      minimumSize: const Size(200, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child:
                                        isLoading
                                            ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text(
                                              'Done',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSocialSignInSection(),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          if (isRequired)
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _dateOfBirthController,
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'yyyy-mm-dd',
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date of birth is required';
          }
          return null;
        },
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _dateOfBirthController.text = picked.toString().split(' ')[0];
            });
          }
        },
      ),
    );
  }

  Widget _buildCountryAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return countries.where((country) {
          return country.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        setState(() {
          _selectedCountry = selection;
          _selectedState = null;
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              hintText: 'Search Country',
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a country';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildStateAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty || _selectedCountry == null) {
          return const Iterable<String>.empty();
        }
        return (countryStates[_selectedCountry] ?? []).where((state) {
          return state.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        setState(() {
          _selectedState = selection;
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              hintText: 'Search State',
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (_selectedCountry != null &&
                  (value == null || value.isEmpty)) {
                return 'Please select a state';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildSocialSignInSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(76),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Or Sign-In with',
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton('assets/google.png', () {}),
              const SizedBox(width: 13),
              _buildSocialButton('assets/microsoft.png', () {}),
              const SizedBox(width: 15),
              _buildSocialButton('assets/apple.png', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          imagePath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            developer.log(
              'Error loading image: $imagePath, Error: $error',
              name: 'RegisterPage',
            );
            return Icon(
              imagePath.contains('google')
                  ? Icons.g_mobiledata
                  : imagePath.contains('microsoft')
                  ? Icons.window
                  : Icons.apple,
              size: 24,
              color: Colors.grey,
            );
          },
        ),
      ),
    );
  }
}

class SuccessPage extends StatefulWidget {
  final String fullName;
  final String email;
  final String? profileImage; 

  const SuccessPage({
    super.key,
    required this.fullName,
    required this.email,
    this.profileImage,
  });

  @override
  SuccessPageState createState() => SuccessPageState();
}

class SuccessPageState extends State<SuccessPage> {
  bool isLoading = false;
  final AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'username': widget.email,
            'fullName': widget.fullName, 
            'profileImage': widget.profileImage,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: TrianglePainter(),
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Account created successfully',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome, ${widget.fullName}!',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSocialSignInSection(),
          ),
        ],
      ),
    );
  }

Widget _buildSocialSignInSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3), // Updated from withOpacity
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Or Sign-In with',
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton('assets/google.png', () {}),
              const SizedBox(width: 15),
              _buildSocialButton('assets/microsoft.png', () {}),
              const SizedBox(width: 15),
              _buildSocialButton('assets/apple.png', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Image.asset(
            imagePath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                imagePath.contains('google')
                    ? Icons.g_mobiledata
                    : imagePath.contains('microsoft')
                        ? Icons.window
                        : Icons.apple,
                size: 24,
                color: Colors.grey,
              );
            },
          ),
          onPressed: () async {
            UserCredential? userCredential;
            try {
              setState(() => isLoading = true);

              if (imagePath.contains('google')) {
                userCredential = await authService.signInWithGoogle();
              } else if (imagePath.contains('apple')) {
                userCredential = await authService.signInWithApple();
              }

              if (mounted && userCredential?.user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuccessPage(
                      fullName: userCredential!.user!.displayName ?? 'User',
                      email: userCredential.user!.email ?? '',
                      profileImage: userCredential.user!.photoURL,
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign in failed: ${e.toString()}')),
                );
              }
            } finally {
              if (mounted) {
                setState(() => isLoading = false);
              }
            }
          },
        ),
      ),
    );
  }
}
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    final secondaryPaint = Paint()
      ..color = Colors.blue.withAlpha(51)
      ..style = PaintingStyle.fill;

    final curvePath1 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.1,
        size.width,
        size.height * 0.2,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.4, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(curvePath1, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}