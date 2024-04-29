package funkin.templates;

class NotePrefixes {
	public static final old = {
		'arrow': [
			['arrowUP'],
			['arrowLEFT', 'arrowRIGHT'],
			['arrowLEFT', 'arrowUP', 'arrowRIGHT'],
			['arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT']
		],
		'hit': [
			['up confirm'],
			['left confirm', 'right confirm'],
			['left confirm', 'up confirm', 'right confirm'],
			['left confirm', 'down confirm', 'up confirm', 'right confirm']
		],
		'ghosted': [
			['up press'],
			['left press', 'right press'],
			['left press', 'up press', 'right press'],
			['left press', 'down press', 'up press', 'right press']
		],
		'note': [
			['green'],
			['purple', 'red'],
			['purple', 'green', 'red'],
			['purple', 'blue', 'green', 'red']
		],
		'holdPattern': [
			['green hold piece'],
			['purple hold piece', 'red hold piece'],
			['purple hold piece', 'green hold piece', 'red hold piece'],
			['purple hold piece', 'blue hold piece', 'green hold piece', 'red hold piece']
		],
		'holdEnd': [
			['green hold end'],
			['pruple end hold', 'red hold end'],
			['pruple end hold', 'green hold end', 'red hold end'],
			['pruple end hold', 'blue hold end', 'green hold end', 'red hold end']
		]
	}
}