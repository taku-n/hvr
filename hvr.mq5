#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100

#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1 "HVR"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrLime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

input int PERIOD = 20;

double hvr[];
double hv[];

int OnInit()
{
	if (Period() >= PERIOD_D1) {
		return 0;
	}

	SetIndexBuffer(0, hvr, INDICATOR_DATA);
	PlotIndexSetString(0, PLOT_LABEL, "HVR(" + IntegerToString(PERIOD) + ")");  // Data Window

	SetIndexBuffer(1, hv, INDICATOR_CALCULATIONS);

	// Chart Window
	IndicatorSetString(INDICATOR_SHORTNAME,
			"HVR(" + IntegerToString(PERIOD) + ")");
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
	if (Period() >= PERIOD_D1) {
		return TOTAL;
	}

	int begin = get_beginning(TOTAL, PREV);

	set_hv(C, begin, TOTAL);
	set_hvr(begin, TOTAL);

	return TOTAL;
}

int get_beginning(const int TOTAL, const int PREV)
{
	int begin;

	if (PREV == 0) {
		begin = 0;
	} else {
		begin = PREV - 1;
	}

	return begin;
}

// Historical Volatility Ratio
void set_hvr(const int BEGIN, const int TOTAL)
{
	double max;
	double ratio;
	for (int i = BEGIN; i < TOTAL; i++) {
		max = get_max_in_day(hv, i);
		if (max != 0.0) {
			ratio = hv[i] / max;
			hvr[i] = ratio * 100.0;
		} else {
			hvr[i] = 0.0;
		}
	}
}

double get_max_in_day(const double &A[], const int I)
{
	if (Period() > PERIOD_D1) {
		return 0.0;
	}

	int period = 1440 / get_period_in_min(Period());

	int begin = I - (period - 1);
	if (begin < 0) {
		begin = 0;
	}
	double max = 0.0;
	for (int i = begin; i <= I; i++) {
		if (A[i] > max) {
			max = A[i];
		}
	}

	return max;
}

// Historical Volatility
void set_hv(const double &C[], const int BEGIN, const int TOTAL)
{
	for (int i = BEGIN; i < TOTAL; i++) {
		hv[i] = get_sd(C, i);
	}
}

// Standard Deviation
double get_sd(const double &C[], const int I)
{
	return MathSqrt(get_var(C, I));
}

// Variance
double get_var(const double &C[], const int I)
{
	const double ave = get_ave(C, I);
	      double sum = 0.0;

	for (int i = I - (PERIOD - 1); i <= I; i++) {
		if (i < 0) {
			sum += (C[0] - ave) * (C[0] - ave);
		} else {
			sum += (C[i] - ave) * (C[i] - ave);
		}
	}

	return sum / PERIOD;
}

// Average
double get_ave(const double &C[], const int I)
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

// Return 0 if period is an invalid value.
int get_period_in_min(const int E_PERIOD)
{
	switch (E_PERIOD) {
	case PERIOD_M1:  // 1
		return 1;
	case PERIOD_M2:  // 2
		return 2;
	case PERIOD_M3:  // 3
		return 3;
	case PERIOD_M4:  // 4
		return 4;
	case PERIOD_M5:  // 5
		return 5;
	case PERIOD_M6:  // 6
		return 6;
	case PERIOD_M10:  // 10
		return 10;
	case PERIOD_M12:  // 12
		return 12;
	case PERIOD_M15:  // 15
		return 15;
	case PERIOD_M20:  // 20
		return 20;
	case PERIOD_M30:  // 30
		return 30;
	case PERIOD_H1:  // 16385
		return 60;
	case PERIOD_H2:  // 16386
		return 120;
	case PERIOD_H3:  // 16387
		return 180;
	case PERIOD_H4:  // 16388
		return 240;
	case PERIOD_H6:  // 16390
		return 360;
	case PERIOD_H8:  // 16392
		return 480;
	case PERIOD_H12:  // 16396
		return 720;
	case PERIOD_D1:  // 16408
		return 1440;
	case PERIOD_W1:  // 32769
		return 10080;
	case PERIOD_MN1:  // 49153
		return 43200;
	}

	return 0;
}
