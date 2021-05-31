#property indicator_separate_window
#property indicator_minimum 0

#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1 "HV"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrLime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

input int PERIOD = 20;

double hv[];

int OnInit()
{
	SetIndexBuffer(0, hv, INDICATOR_DATA);
	PlotIndexSetString(0, PLOT_LABEL, "HV(" + IntegerToString(PERIOD) + ")");  // Data Window

	// Chart Window
	IndicatorSetString(INDICATOR_SHORTNAME,
			"HV(" + IntegerToString(PERIOD) + ") pips/min");
	IndicatorSetInteger(INDICATOR_DIGITS, 3);

	return INIT_SUCCEEDED;
}

int OnCalculate(const int       TOTAL,
		const int       PREV,
		const datetime &T[],
		const double   &O[],
		const double   &H[],
		const double   &L[],
		const double   &C[],
		const long     &TICK_VOL[],
		const long     &VOL[],
		const int      &SP[])
{
	hv(C, TOTAL, PREV);

	return TOTAL;
}

// Historical Volatility
void hv(const double &C[], const int TOTAL, const int PREV)
{
	int begin;
	if (PREV == 0) {
		begin = 0;
	} else {
		begin = PREV - 1;
	}

	double pip;
	if (_Digits == 2) {
		pip = 0.01;
	} else if (_Digits == 3) {
		pip = 0.01;
	} else {
		pip = 0.0001;
	}

	for (int i = begin; i < TOTAL; i++) {
		hv[i] = (sd(C, i) / period()) / pip;
	}
}

// Standard Deviation
double sd(const double &C[], const int I)
{
	return MathSqrt(variance(C, I));
}

double variance(const double &C[], const int I)
{
	const double avg = avg(C, I);
	      double sum = 0.0;

	for (int i = I - (PERIOD - 1); i <= I; i++) {
		if (i < 0) {
			sum += (C[0] - avg) * (C[0] - avg);
		} else {
			sum += (C[i] - avg) * (C[i] - avg);
		}
	}

	return sum / PERIOD;
}

double avg(const double &C[], const int I)
{
	double sum = 0.0;

	for (int i = I - (PERIOD - 1); i <= I; i++) {
		if (i < 0) {
			sum += C[0];
		} else {
			sum += C[i];
		}
	}

	return sum / PERIOD;
}

int period()
{
	switch (_Period) {
	case PERIOD_M1:
		return 1;
	case PERIOD_M2:
		return 2;
	case PERIOD_M3:
		return 3;
	case PERIOD_M4:
		return 4;
	case PERIOD_M5:
		return 5;
	case PERIOD_M6:
		return 6;
	case PERIOD_M10:
		return 10;
	case PERIOD_M12:
		return 12;
	case PERIOD_M15:
		return 15;
	case PERIOD_M20:
		return 20;
	case PERIOD_M30:
		return 30;
	case PERIOD_H1:
		return 60;
	case PERIOD_H2:
		return 120;
	case PERIOD_H3:
		return 180;
	case PERIOD_H4:
		return 240;
	case PERIOD_H6:
		return 360;
	case PERIOD_H8:
		return 480;
	case PERIOD_H12:
		return 720;
	case PERIOD_D1:
		return 1440;
	case PERIOD_W1:
		return 10080;
	case PERIOD_MN1:
		return 43200;
	}

	return _Period;
}
