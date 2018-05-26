#define N 10
#define ITERS 100000

int a[N];

bool is_connected = false;
bool is_syclic = false;
bool is_shorter_then_3 = false;

inline rand(x, max) {
    x = 0;
    select(x: 1..max)
}

inline is_syclic_check() {
    bool used[N];
    int counter_null = 0;
    do
        :: counter_null < N -> 
            used[counter_null] = false;
            counter_null++;
        :: else ->
            break;
    od;
    
    int current = 1;
    do 
        :: current == N - 1 -> 
            break;
        :: current == 0 -> 
            break;
        :: used[current] == true ->
            printf("CYCLE %d %d %d %d\n", a[1], a[2], a[3], a[4])
            is_syclic = true;
            break;
        :: else ->
            used[current] = true;
            current = a[current];
    od;
}

inline pre_add(x) {
    x = false;
    bool used[N];
    int counter_null = 0;
    do
        :: counter_null < N -> 
            used[counter_null] = false;
            counter_null++;
        :: else ->
            break;
    od;
    int current = 1;
    do 
        :: current == N - 1 -> 
            break;
        :: current == 0 -> 
            break;
        :: used[current] == true ->
            x = true;
            break;
        :: else ->
            used[current] = true;
            current = a[current];
    od;
}

inline is_connected_check() {
    is_syclic_check();
    int current = 1;
    int hops = 0;
    do 
        :: is_syclic == true ->
            break;
        :: current == N - 1 -> 
            is_connected = true;
            if
                :: hops < 3 ->
                    is_shorter_then_3 = true;
                :: else -> skip;
            fi;
            break;
        :: current == 0 ->
            is_connected = false;
            break;
        :: else ->
            hops++;
            current = a[current];
    od;
}

inline add_route(x) {
    atomic {
    int y = 0;
    bool added = false;
    int count = 0;
    bool check = false;
    do
        :: count > 15 ->
            break;
        :: added == true ->
            break;
        :: y == 0 ->
            rand(y, N-1);
        :: else ->
            count++;
            int prev = a[x];
            a[x] = y;
            check = false;
            pre_add(check);
            printf("result %d %d %d\n", y, prev, check);
            if
                :: check == false && prev != a[x] -> 
                    added = true;
                    printf("Added = true\n")
                :: else ->  
                    a[x] = prev;
                    y = 0;
                    printf("Reroll\n")
            fi;
    od;
    is_connected_check();
    }
}

inline delete_route(x) {
    atomic {
    a[x] = 0;
    is_connected_check();
    }
}

inline print_array() {
    int counter_null = 0;
    do
        :: counter_null < N -> 
            printf("%d ", a[counter_null]);
            counter_null++;
        :: else ->
            break;
    od;
    printf("\n");
}

active proctype Main() {
    printf("Started building graph randomly\n");
    int action = 1;
    int x = 0;
    int iter = 0;
    do
        :: is_shorter_then_3 -> 
            break;
        :: else ->  
            rand(x, N - 1);
            printf("adding %d\n", x);
            add_route(x);
    od;
    print_array();
}

ltl eventually_connected {<>(is_connected)}
ltl eventually_connected_with_path_shorter_then_3 {<>(is_shorter_then_3)}
ltl always_asyclick {[](!is_syclic)}
