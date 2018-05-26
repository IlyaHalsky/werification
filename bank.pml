#define CLIENS 10
#define CASH 10
#define FEE_MAX 50
#define TRANSFER_MAX 50
#define MAX_WAIT 50

int account[CLIENS];
int lock[CLIENS];
int dead[CLIENS];

int transactions = 0;
int max_transactions = 0;

bool all_broke = false;
bool release_read_lock_error = false;

inline all_broke_check() {
    int counter = 0;
    int sum = 0;
    atomic {
        do
            :: counter < CLIENS ->
                sum = sum + account[counter];
                counter++;
            :: else ->
                break;
        od;
    }
    printf("[%d]%d %d %d %d\n", sum, account[0],account[1],account[2],account[3]);
    bool answer = sum == 0;
    printf("[%d] All Broke %d\n", _pid, answer);
    all_broke = answer;
}

inline get_single_lock(id, got_it){
    got_it = false;
    int counter = 0;
    atomic{
    do
        :: lock[id] == 0 ->
            lock[id] = _pid+1;
            printf("[%d] Got lock on %d\n", _pid, id);
            got_it = true;
            break;
        :: counter > MAX_WAIT ->
            got_it = false;
            break;
        :: else ->
            printf("[%d] Waiting for lock on %d, %d\n", _pid, id, lock[id]);
            counter++;
    od;
    }
    printf("Locks: %d %d %d\n", lock[0], lock[1], lock[2]);
}

inline release_single_lock(id){
    atomic{
    if
        :: lock[id] != _pid+1 ->
            release_read_lock_error = false;
            lock[id] = 0;
            printf("[%d] Released lock on %d\n", _pid, id);
        :: else ->
            lock[id] = 0;
            printf("[%d] Released lock on %d\n", _pid, id);
    fi;
    }
    printf("Locks: %d %d %d\n", lock[0], lock[1], lock[2]);
}

inline broke(id, x) {
    printf("[%d] Cheking if broke %d\n", _pid, id);
    bool got_it = false;
    get_single_lock(id, got_it);
    if
        :: got_it ->
            x = account[id] <= 0;
            printf("[%d] Account value: %d\n", _pid, account[id]);
            release_single_lock(id);
        :: else ->
            skip;
    fi;
}

inline min_or_zero(a) {
    if
        :: a < 0 -> 
            a = 0;
        :: else -> 
            skip;
    fi;
}

inline pay_fee(id, value) {
    printf("[%d] Paying fee %d\n", _pid, value);
    bool got_it = false;
    get_single_lock(id, got_it);
    if
        :: got_it ->
            int new_value = account[id] - value;
            min_or_zero(new_value);
            account[id] = new_value;
            release_single_lock(id);
        :: else ->
            skip;
    fi;
}

inline get_double_lock(id1, id2, got_it){
    bool got_it_1 = false;
    bool got_it_2 = false;
    if
        :: id1 < id2 ->
            get_single_lock(id1, got_it_1);
            if
                :: got_it_1 ->
                    get_single_lock(id2, got_it_2);
                :: else ->
                    release_single_lock(id1);
            fi;
            got_it = got_it_2
        :: id1 > id2 ->
            get_single_lock(id2, got_it_1);
            if
                :: got_it_1 ->
                    get_single_lock(id1, got_it_2);
                :: else ->
                    release_single_lock(id2);
            fi;
            got_it = got_it_2
        :: id1 == id2 ->
            printf("[%d] Shoudn't happen\n", _pid);
    fi;
}

inline release_double_lock(id1, id2){
    if
        :: id1 < id2 ->
            release_single_lock(id2);
            release_single_lock(id1);
        :: id1 > id2 ->
            release_single_lock(id1);
            release_single_lock(id2);
        :: id1 == id2 ->
            printf("[%d] Shoudn't happen 2\n", _pid);
    fi;
}

inline get_avalible_sum(id, value){
    printf("[%d] Checking avalible sum\n", _pid);
    bool got_it = false;
    get_single_lock(id, got_it);
    if 
        :: got_it ->
            int savings = account[id];
            if
                :: savings >= value ->
                    skip;
                :: else ->
                    value = savings;
            fi;
            release_single_lock(id);
        :: else ->
            skip;
    
}

inline transfer_money(id1, id2, value){
    bool id2_broke = false;
    broke(id2, id2_broke);
    if
        :: id1 != id2 && !id2_broke->
            printf("[%d] Transfering %d to %d\n", _pid, value, id2);
            int transfer_sum = value;
            bool got_it = false;
            get_double_lock(id1, id2, got_it);
            if 
                :: got_it ->
                    transactions++;
                    int savings = account[id1];
                    if
                        :: savings >= transfer_sum ->
                            skip;
                        :: else ->
                            transfer_sum = savings;
                    fi;

                    int old_sum = account[id1];
                    account[id1] = old_sum - transfer_sum;
                    int new_sum = account[id2];
                    account[id2] = new_sum + transfer_sum;
                    transactions--;
                    release_double_lock(id1, id2);
                :: else ->
                    skip;
            fi;
        :: else ->  
            skip;
    fi;
}

inline rand(x, from, up_to) {
        x = 0;
        select(x: from..up_to)
}


active [CLIENS] proctype client() {
    account[_pid] = CASH;
    bool is_broke = false;
    int money = 0;
    int user = 0;
    printf("[%d] Account value: %d\n", _pid, account[_pid]);
    do
        :: is_broke ->
            break;
        :: 
            rand(money, 1,  FEE_MAX);
            pay_fee(_pid, money);
            broke(_pid, is_broke);
        ::
            rand(money,1, TRANSFER_MAX);
            rand(user, 0, CLIENS - 1);
            transfer_money(_pid, user, money);
            broke(_pid, is_broke);
    od;
    all_broke_check();
    printf("Broke: %d\n", all_broke);
    printf("Trans: %d\n", max_transactions);
    printf("Error: %d\n", release_read_lock_error);
}

active proctype Watcher() {
    do
        :: all_broke ->
            break;
        :: max_transactions > 1 ->  
            printf("More then one transaction -----------------\n");
            break;
        :: release_read_lock_error ->
            printf("Release error ----------------------\n");
            break;
        :: else ->
            if
                :: transactions > max_transactions ->
                    max_transactions = transactions;
                :: else ->
                    skip;
            fi;
    od;
}

ltl all_broke_eventually{<>(all_broke)}
ltl more_then_one_transaction_at_the_time{<>(transactions > 1)}
ltl always_correct_lock_release{[](!release_read_lock_error)}