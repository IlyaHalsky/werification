int res = 0;
int cur_a = 1;
int cur_n = 1;
int m = 0;

bool is_correct_power = true;
bool divide = true;
bool divide_during_power = true;

proctype binpow(int a; int n) {
	if
		:: n == 0 ->
			res = 1; 
			m = 1;
		:: else ->
			if
				:: n % 2 == 1 ->
					run binpow(a, n - 1);	
					res = res * a;
				:: else -> 	
					run binpow(a, n / 2);	
					res = res * res;
			fi
			if 
				:: res % a != 0 -> divide_during_power = false;
				:: else -> skip;
			fi	
	fi
}

inline check_correctness() {
	int cur_res = res;
	int cur_n_here = cur_n;
	do
		:: cur_res == 1 -> 
			if
				:: cur_n_here == 0 ->
					m = 0;
					is_correct_power = true;
					break;
				:: else ->
					is_correct_power = false
			fi
		:: else ->
			if
				:: cur_n_here == 0 ->
					is_correct_power = false;
					break;
				:: else -> 
					if
						:: cur_res % cur_a == 0 ->
							cur_res	= cur_res / cur_a;
							cur_n_here--;
						:: else ->
							divide = false;
					fi
			fi
	od					
}

active proctype Main() {
	m = 0;
    printf("started\n");
    do
        :: m == 0 ->
            res = 0;
            cur_a++;
            cur_n++;
            printf("Calculating %d ^ %d\n", cur_a, cur_n);
            run binpow(cur_a, cur_n);
            printf("Calculated, result is %d \n", res);
        :: m == 1 ->
        	printf("Checking correctness of %d ^ %d, res is %d", cur_a, cur_n, res);
        	if
        		:: res == 0 -> skip;
        		:: else -> check_correctness();
        	fi	
        od;
}

ltl forever_divide_during_power {[](divide_during_power)}
ltl forever_correct_divide {[](divide)}
ltl forever_correct_power {[](is_correct_power)}