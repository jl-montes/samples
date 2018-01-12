
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <iostream>
using namespace std;

// metric and standard unit conversion definitions
#define KILOMETERS_PER_MILE 	1.60934
#define MILES_PER_KILOMETER 	0.621371
#define LBS_PER_KILOGRAM 	2.20462
#define KILOGRAMS_PER_LBS 	0.453592
#define METERS_PER_FEET		0.3048
#define FEET_PER_METER		3.2808
#define CENTIMETERS_PER_INCH	2.54
#define INCHES_PER_CENTIMETER	0.393701
#define MILLIMETERS_PER_INCH	25.4
#define INCHES_PER_MILLIMETER	0.0393701
#define GRAMS_PER_OUNCE		28.35
#define OUNCES_PER_GRAM		0.035274


// menu option to force exit, value entered by user 
#define  LAST_OPTION 99


class MetricConversion {
    private:
        double input, output;
        
    public:
        void test();
        void collect_value (const char *from, const char *to);
        void miles_to_kilometers();
        void kilometers_to_miles();
        void lbs_to_kilograms();
        void kilograms_to_lbs();
        void meters_to_feet();
        void feet_to_meters();
        void inches_to_centimeters();
        void centimeters_to_inches();
        void inches_to_millimeters();
        void millimeters_to_inches();
        void ounces_to_grams();
        void grams_to_ounces();
        void fahrenheit_to_celsius();
        void celsius_to_fahrenheit();
        double GetInput();
        double GetOutput();
        MetricConversion();
        ~MetricConversion();

};
// default constructor
MetricConversion::MetricConversion()
{
    input = output = 0;
    cout << "\n\t\tinitilizing class instance...\n";
}
// default destructor
MetricConversion::~MetricConversion()
{
    cout << "\n\t\tremoving initilized class from memory...\n";
}

double MetricConversion::GetInput()
{
   return input;
}

double MetricConversion::GetOutput()
{
   return output;
}

void MetricConversion::test()
{
   cout << "\nThis is a Class test..."
           "\neverything is working yeah..." ;
}

int cls(void);

int show_menu(void);


int main(void)
{

    show_menu();

    return 0;  

}

void MetricConversion::collect_value(const char *from, const char *to)
{
    double input_value;
    input_value = 0;

    printf("\n\t\tConvert %s to %s"
           "\n\t\tEnter a value in %s: ", from, to, from);

    scanf("%lf", &input_value);
    input = input_value;
}

void MetricConversion::miles_to_kilometers()
{
    output = KILOMETERS_PER_MILE * input;
}

void MetricConversion::kilometers_to_miles()
{
    output = MILES_PER_KILOMETER * input;
}

void MetricConversion::lbs_to_kilograms()
{
    output = KILOGRAMS_PER_LBS * input;
} 

void MetricConversion::kilograms_to_lbs()
{
    output = LBS_PER_KILOGRAM * input;
} 

void MetricConversion::feet_to_meters()
{
    output = METERS_PER_FEET * input;
} 

void MetricConversion::meters_to_feet()
{
    output = FEET_PER_METER * input;
} 

void MetricConversion::inches_to_centimeters()
{
    output = CENTIMETERS_PER_INCH * input;
} 

void MetricConversion::centimeters_to_inches()
{
    output = INCHES_PER_CENTIMETER * input;
} 

void MetricConversion::inches_to_millimeters()
{
    output = MILLIMETERS_PER_INCH * input;
} 

void MetricConversion::millimeters_to_inches()
{
    output = INCHES_PER_MILLIMETER * input;
} 

void MetricConversion::ounces_to_grams()
{
    output = GRAMS_PER_OUNCE * input;
} 

void MetricConversion::grams_to_ounces()
{
    output = OUNCES_PER_GRAM * input;
} 

void MetricConversion::fahrenheit_to_celsius()
{
    output = (5.0 / 9.0) * (input - 32.0);
} 

void MetricConversion::celsius_to_fahrenheit()
{
    output = (9.0 / 5.0) * input + 32.0; 
} 

int show_menu(void)
{
    int c, d;
    c = 0;

    MetricConversion Metrics;

    while(  c != LAST_OPTION ) {
         /* cls(); */
         fflush(stdin);
         printf("\n\n\t\tSelect an option from the menu"
                "\n\t\t-----------------------------"
                "\n\t\t1) Convert Miles to Kilometers"
                "\n\t\t2) Convert Kilometers to Miles"
                "\n\t\t3) Convert Lbs to Kilograms"
                "\n\t\t4) Convert Kilograms to Lbs"
                "\n\t\t5) Convert Feet to Meters"
                "\n\t\t6) Convert Meters to Feet"
                "\n\t\t7) Convert Inches to Centimeters"
                "\n\t\t8) Convert Centimeters to Inches"
                "\n\t\t9) Convert Inches to Millimeters"
                "\n\t\t10) Convert Millimeters to Inches"
                "\n\t\t11) Convert Ounces to Grams"
                "\n\t\t12) Convert Grams to Ounces"
                "\n\t\t13) Convert Fahrenheit to Celsius"
                "\n\t\t14) Convert Celsius to Fahrenheit"
                "\n\t\t99) Quit\n"
                "\n\t\tSelect an option from the menu: ");
         
         scanf("%2d", &c);


         switch (c) {
             case 1: Metrics.collect_value("Miles", "Kilometers");
                       Metrics.miles_to_kilometers();
                       //Metrics.miles_to_kilometers(input_value);
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Miles", Metrics.GetOutput(), "Kilometers");
                       break;
             case 2: Metrics.collect_value("Kilometers", "Miles");
                       Metrics.kilometers_to_miles();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Kilometers", Metrics.GetOutput(), "Miles");
                       break;
             case 3: Metrics.collect_value("Pounds (Lbs)", "Kilograms");
                       Metrics.lbs_to_kilograms();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Pounds (Lbs)", Metrics.GetOutput(), "Kilograms");
                       break;
             case 4: Metrics.collect_value("Kilograms", "Pounds (Lbs)");
                       Metrics.kilograms_to_lbs();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Kilograms", Metrics.GetOutput(), "Pounds (Lbs)");
                       break;
             case 5: Metrics.collect_value("Feet","Meters");
                       Metrics.feet_to_meters();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Feet", Metrics.GetOutput(), "Meters");
                       break;
             case 6: Metrics.collect_value("Meters","Feet");
                       Metrics.meters_to_feet();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Meters", Metrics.GetOutput(), "Feet");
                       break;
             case 7: Metrics.collect_value("Inches", "Centimeters");
                       Metrics.inches_to_centimeters();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Inches", Metrics.GetOutput(), "Centimeters");
                       break;
             case 8: Metrics.collect_value("Centimeters", "Inches");
                       Metrics.centimeters_to_inches();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Centimeters", Metrics.GetOutput(), "Inches");
                       break;
             case 9: Metrics.collect_value("Inches", "Millimeters");
                       Metrics.inches_to_millimeters();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Inches", Metrics.GetOutput(), "Millimeters");
                       break;
             case 10:  Metrics.collect_value("Millimeters", "Inches");
                       Metrics.millimeters_to_inches();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Millimeters", Metrics.GetOutput(), "Inches");
                       break;
             case 11:  Metrics.collect_value("Ounces", "Grams");
                       Metrics.ounces_to_grams();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Ounces", Metrics.GetOutput(), "Grams");
                       break;
             case 12:  Metrics.collect_value("Grams", "Ounces");
                       Metrics.grams_to_ounces();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Grams", Metrics.GetOutput(), "Ounces");
                       break;
             case 13:  Metrics.collect_value("Fahrenheit", "Celsius");
                       Metrics.fahrenheit_to_celsius();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Fahrenheit", Metrics.GetOutput(), "Celsius");
                       break;
             case 14:  Metrics.collect_value("Celsius", "Fahrenheit");
                       Metrics.celsius_to_fahrenheit();
                       printf("\n\t\t%0.2f %s = %0.2f %s\n", Metrics.GetInput(), "Celsius", Metrics.GetOutput(), "Fahrenheit");
                       break;
             case LAST_OPTION: printf("\n\t\tExiting...\n\n"); break;
             default: printf("\n\t\tInvalid Option... --> '%d'", c); break;

         }
         // create a short delay and display results before re-paining menu
         if ( c != 99 )
             sleep(3);
    }

}
int cls()
{
    system("clear");
}

