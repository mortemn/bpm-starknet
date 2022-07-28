#include <iostream>

using namespace std;

int main()
{
    double x = 1;
    for (int i = 0; i <= 252; ++i) {
        x *= 2;
        cout << "Power of " << i+1 << ": " << x << endl;
    }
}

