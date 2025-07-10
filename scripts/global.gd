extends Node

enum TYPE {
	ENTRIES,
	PLAIN_PLACEHOLDER,
	PLACEHOLDER,
	NUMBER,
	POWER,
	LOGARITHM,
	OPERATOR,
	VARIABLE,
	FUNCTION,
	SQUARE_ROOT,
	CONSTANT,
	PERMUTATION,
	COMBINATION,
	MODULUS,
	FACTORIAL,
	FRACTION,
	ERROR
}
enum OUTPUT_TYPE {
	FRACTION,
	DECIMAL
}
enum OPTIONS {
	ZERO,
	ONE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	SHIFT,
	ALPHA,
	UP,
	MENU,
	ON,
	OPTION,
	CALCULATE,
	LEFT,
	RIGHT,
	ALGEBRA,
	DOWN,
	FRACTION,
	SQUARE_ROOT,
	POWER_OF_TWO,
	POWER,
	LOGARITHMS,
	NATURAL_LOGARITHM,
	POWER_OF_NEGATIVE_ONE,
	SINE,
	COSINE,
	TANGENT,
	LEFT_PARENTHESIS,
	RIGHT_PARENTHESIS,
	DELETE,
	ALL_CLEAR,
	MULTIPLY,
	DIVIDE,
	PLUS,
	MINUS,
	DOT,
	ANSWER,
	EQUAL,
	MIXED_FRACTION,
	CUBE_ROOT,
	POWER_OF_THREE,
	ROOT,
	TEN_POWER,
	EULER_POWER,
	LOG,
	FACTORIAL,
	ARCSINE,
	ARCCOSINE,
	ARCTANGENT,
	ABSOLUTE, # MODULUS
	COMMA,
	CONSTANT,
	CONV,
	RESET,
	INSERT,
	OFF,
	PERMUTATION,
	COMBINATION,
	POLAR,
	RECTANGULAR,
	RANDOM,
	RANDOM_INTEGER,
	PI,
	PERCENTAGE,
	APPROXIMATE
}
const FONT: FontFile = preload("res://fonts/fusion_pixel_10px_monospaced.otf")
const KEYBOARD = [
	[
		['SHIFT', OPTIONS.SHIFT],
		['ALPHA', OPTIONS.ALPHA],
		['^', OPTIONS.UP],
		['MENU', OPTIONS.MENU],
		['ON', OPTIONS.ON]
	],
	[
		['OPTN', OPTIONS.OPTION],
		['CALC', OPTIONS.CALCULATE],
		['<', OPTIONS.LEFT],
		['>', OPTIONS.RIGHT],
		['???', -1],
		['x', OPTIONS.ALGEBRA]
	],
	[
		['v', OPTIONS.DOWN]
	],
	[
		['▯/▯', OPTIONS.FRACTION],
		['√▯', OPTIONS.SQUARE_ROOT],
		['x²', OPTIONS.POWER_OF_TWO],
		['x▝', OPTIONS.POWER],
		['log▗▯', OPTIONS.LOGARITHMS],
		['ln', OPTIONS.NATURAL_LOGARITHM]
	],
	[
		['°\'"', -1],
		['x⁻¹', OPTIONS.POWER_OF_NEGATIVE_ONE],
		['sin', OPTIONS.SINE],
		['cos', OPTIONS.COSINE],
		['tan', OPTIONS.TANGENT]
	],
	[
		['STO', -1],
		['ENG', -1],
		['(', OPTIONS.LEFT_PARENTHESIS],
		[')', OPTIONS.RIGHT_PARENTHESIS],
		['S⇔D', -1],
		['M+', -1]
	],
	[
		['7', OPTIONS.SEVEN],
		['8', OPTIONS.EIGHT],
		['9', OPTIONS.NINE],
		['DEL', OPTIONS.DELETE],
		['AC', OPTIONS.ALL_CLEAR]
	],
	[
		['4', OPTIONS.FOUR],
		['5', OPTIONS.FIVE],
		['6', OPTIONS.SIX],
		['×', OPTIONS.MULTIPLY],
		['÷', OPTIONS.DIVIDE]
	],
	[
		['1', OPTIONS.ONE],
		['2', OPTIONS.TWO],
		['3', OPTIONS.THREE],
		['+', OPTIONS.PLUS],
		['-', OPTIONS.MINUS]
	],
	[
		['0', OPTIONS.ZERO],
		['.', OPTIONS.DOT],
		['×10ˣ', -1],
		['ANS', OPTIONS.ANSWER],
		['=', OPTIONS.EQUAL]
	]
]
const SHIFTED_KEYBOARD = [
	[
		['SHIFT', OPTIONS.SHIFT],
		['ALPHA', OPTIONS.ALPHA],
		['^', OPTIONS.UP],
		['SETUP', -1],
		['ON', OPTIONS.ON]
	],
	[
		['QR', -1],
		['SOLVE', -1],
		['<', OPTIONS.LEFT],
		['>', OPTIONS.RIGHT],
		['???', -1],
		['???', -1]
	],
	[
		['v', OPTIONS.DOWN]
	],
	[
		['▯(▯/▯)', OPTIONS.MIXED_FRACTION],
		['∛', OPTIONS.CUBE_ROOT],
		['x³', OPTIONS.POWER_OF_THREE],
		['▝√', OPTIONS.ROOT],
		['10▝', OPTIONS.TEN_POWER],
		['e▝', OPTIONS.EULER_POWER]
	],
	[
		['log', OPTIONS.LOG],
		['FACT', -1],
		['!', OPTIONS.FACTORIAL],
		['sin⁻¹', OPTIONS.ARCSINE],
		['cos⁻¹', OPTIONS.ARCCOSINE],
		['tan⁻¹', OPTIONS.ARCTANGENT]
	],
	[
		['RECALL', -1],
		['∠', -1],
		['ABS', OPTIONS.ABSOLUTE],
		[',', OPTIONS.COMMA],
		['a b/c⇔d/c', -1],
		['M-', -1]
	],
	[
		['CONST', OPTIONS.CONSTANT],
		['CONV', OPTIONS.CONV],
		['RESET', OPTIONS.RESET],
		['INS', OPTIONS.INSERT],
		['OFF', OPTIONS.OFF]
	],
	[
		['4', OPTIONS.FOUR],
		['5', OPTIONS.FIVE],
		['6', OPTIONS.SIX],
		['nPr', OPTIONS.PERMUTATION],
		['nCr', OPTIONS.COMBINATION]
	],
	[
		['1', OPTIONS.ONE],
		['2', OPTIONS.TWO],
		['3', OPTIONS.THREE],
		['Pol', OPTIONS.POLAR],
		['Rec', OPTIONS.RECTANGULAR]
	],
	[
		['Rnd', OPTIONS.RANDOM],
		['RndInt', OPTIONS.RANDOM_INTEGER],
		['π', OPTIONS.PI],
		['%', OPTIONS.PERCENTAGE],
		['≈', OPTIONS.APPROXIMATE]
	]
]

enum CONSTANT_CATEGORIES {
	UNIVERSAL,
	ELECTROMAGNETIC,
	ATOMIC_AND_NUCLEAR,
	PHYSICO_CHEMICAL,
	ADOPTED_VALUES,
	OTHER,
	NULL
}

const EULER_NUMBER: float = 2.718_281_828
const CONSTANTS: Dictionary[String, Dictionary] = {
	UNIVERSAL = {
		PLANCK_CONSTANT = {display = 'h', value = 6.626_069_57, exp = -34},
		REDUCED_PLANCK_CONSTANT = {display = 'ħ', value = 1.054_571_726, exp = -34},
		VACUUM_SPEED_OF_LIGHT = {display = 'c₀', value = 299_792_458},
		VACUUM_PERMITTIVITY = {display = 'ε₀', value = 8.854_187_817, exp = -12}, # ELECTRIC_CONSTANT
		VACUMM_PERMEABILITY = {display = 'μ₀', value = 1.256_637_061, exp = -6}, # MAGNETIC_CONSTANT
		VACUMM_IMPEDANCE = {display = 'Z₀', value = 376.730_313_5},
		GRAVITATION_CONSTANT = {display = 'G', value = 6.673_84, exp = -11},
		PLANCK_LENGTH = {display = 'lp', value = 1.616_199, exp = -35},
		PLANCK_TIME = {display = 'tp', value = 5.391_06, exp = -44}
	},
	ELECTROMAGNETIC = {
		NUCLEAR_MAGNETON = {display = 'μN', value = 5.050_783_53, exp = -27},
		BOHR_MAGNETON = {display = 'μB', value = 9.274_009_68, exp = -24},
		ELEMENTARY_CHARGE = {display = 'e', value = 1.602_176_565, exp = -19},
		MAGNETIC_FLUX_QUANTUM = {display = 'Φ₀', value = 2.067_833_758, exp = -15},
		CONDUCTANCE_QUANTUM = {display = 'G₀', value = 7.748_091_735, exp = -5},
		JOSEPHSON_CONSTANT = {display = 'kJ', value = 4.835_978_7, exp = 14},
		VON_KLITZING_CONSTANT = {display = 'RK', value = 25_812.807_44}
	},
	ATOMIC_AND_NUCLEAR = {
		PROTON_MASS = {display = 'mp', value = 1.672_621_777, exp = -27},
		NEUTRON_MASS = {display = 'mn', value = 1.674_927_351, exp = -27},
		ELECTRON_MASS = {display = 'me', value = 9.109_382_91, exp = -31},
		MUON_MASS = {display = 'mµ', value = 1.883_531_475, exp = -28},
		BOHR_RADIUS = {display = 'a₀', value = 5.291_772_109_2, exp = -11},
		FINE_STRUCTURE_CONSTANT = {display = 'a', value = 7.297_352_569_8, exp = -3},
		CLASSICAL_ELECTRON_RADIUS = {display = 're', value = 2.817_940_327, exp = -15},
		COMPTON_WAVELENGTH = {display = 'λc', value = 2.426_310_239, exp = -12},
		PROTON_GYROMAGNETIC_RATIO = {display = 'γp', value = 267_522_200.5},
		PROTON_COMPTON_WAVELENGTH = {display = 'λcp', value = 1.321_409_856, exp = -15},
		NEUTRON_COMPTON_WAVELENGTH = {display = 'λcn', value = 1.319_590+907, exp = -15},
		RYDBERG_CONSTANT = {display = 'R∞', value = 10_973_731.568_539},
		PROTON_MAGNETIC_MOMENT = {display = 'µp', value = 1.410_606_743, exp = -26},
		ELECTRON_MAGNETIC_MOMENT = {display = 'µe', value = -9.284_764_3, exp = -24},
		NEUTRON_MAGNETIC_MOMENT = {display = 'µn', value = -9.662_364_7, exp = -27},
		MUON_MAGNETIC_MOMENT = {display = 'µµ', value = -4.490_448_07, exp = -26},
		TAU_MASS = {display = 'mτ', value = 3.167_47, exp = -27}
	},
	PHYSICO_CHEMICAL = {
		ATOMIC_MASS_CONSTANT = {display = 'u', value = 1.660_538_921, exp = -27},
		FARADAY_CONSTANT = {display = 'F', value = 96_485.336_5},
		AVOGADRO_CONSTANT = {display = 'NA', value = 6.022_141_29, exp = 23},
		BOLTZMANN_CONSTANT = {display = 'k', value = 1.380_648_8, exp = -23},
		MOLAR_VOLUME_OF_IDEAL_GAS = {display = 'Vm (273.15 K, 100 kPa)', value = 0.022_710_953},
		MOLAR_GAS_CONSTANT = {display = 'R', value = 8.314_462_1},
		FIRST_RADIATION_CONSTANT = {display = 'c1', value = 3.741_771_53, exp = -16},
		SECOND_RADIATION_CONSTANT = {display = 'c2', value = 0.014_387_77},
		STEFAN_BOLTZMANN_CONSTANT = {display = 'σ', value = 5.670_373, exp = -8}
	},
	ADOPTED_VALUES = {
		STANDARD_ACCELERATION_OF_GRAVITY = {display = 'g', value = 9.806_65},
		STANDARD_ATMOSPHERE = {display = 'atm (SI unit: Pa)', value = 101_325},
		CONVENTIONAL_VALUE_OF_VON_KLITZING_CONSTANT = {display = 'RK–90', value = 25_812.807},
		CONVENTIONAL_VALUE_OF_JOSEPHSON_CONSTANT = {display = 'KJ–90', value = 483_597.9}
	},
	OTHER = {
		CELSIUS_TEMPERATURE = {display = 't', value = 273.15}
	}
}
enum VARIANT_TYPE {
	TYPE_NIL,
	TYPE_BOOL,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_VECTOR2,
	TYPE_VECTOR2I,
	TYPE_RECT2,
	TYPE_RECT2I,
	TYPE_VECTOR3,
	TYPE_VECTOR3I,
	TYPE_TRANSFORM2D,
	TYPE_VECTOR4,
	TYPE_VECTOR4I,
	TYPE_PLANE,
	TYPE_QUATERNION,
	TYPE_AABB,
	TYPE_BASIS,
	TYPE_TRANSFORM3D,
	TYPE_PROJECTION,
	TYPE_COLOR,
	TYPE_STRING_NAME,
	TYPE_NODE_PATH,
	TYPE_RID,
	TYPE_OBJECT,
	TYPE_CALLABLE,
	TYPE_SIGNAL,
	TYPE_DICTIONARY,
	TYPE_ARRAY,
	TYPE_PACKED_BYTE_ARRAY,
	TYPE_PACKED_INT32_ARRAY,
	TYPE_PACKED_INT64_ARRAY,
	TYPE_PACKED_FLOAT32_ARRAY,
	TYPE_PACKED_FLOAT64_ARRAY,
	TYPE_PACKED_STRING_ARRAY,
	TYPE_PACKED_VECTOR2_ARRAY,
	TYPE_PACKED_VECTOR3_ARRAY,
	TYPE_PACKED_COLOR_ARRAY,
	TYPE_PACKED_VECTOR4_ARRAY,
	TYPE_MAX
}
enum PAGES {
	MAIN,
	CONSTANT_CATEGORY,
	CONSTANT
}

var output_type: OUTPUT_TYPE = OUTPUT_TYPE.FRACTION

"""
func _ready():
	var counter: int = 0
	
	for category in CONSTANTS:
		counter += CONSTANTS[category].size()
	
	print(counter)
"""
