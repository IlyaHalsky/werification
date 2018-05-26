#define SIZE 8
#define good_size (0 <= m && m <= SIZE)
#define inc (m == pm + 1)
#define dec (m == pm - 1)
#define full (m == SIZE)
#define empty (m == 0)
#define smaller (res <= a[0])
 
int a[SIZE];
int ii;
int m;
int pm;
int res;
 
bool is_heap = true;
bool adding = false;
bool extracting = false;
bool has_last = false;
 
inline isHeap() {
        is_heap = true;
        int index = 0;
        do
                :: index >= m -> break;
                :: else ->
                        if
                                :: 2 * index + 1 < m && a[index] > a[2 * index + 1] -> is_heap = false; break;
                                :: else -> skip;
                        fi;
                        if
                                :: 2 * index + 2 < m && a[index] > a[2 * index + 2] -> is_heap = false; break;
                                :: else -> skip;
                        fi;
                        index++;
        od;
}
 
inline find(x) {
        has_last = false;
        int index2 = 0;
        do
                :: index2 >= m -> break;
                :: else ->
                        if
                                :: a[index2] == x -> has_last = true; break;
                                :: else -> index2++;
                        fi;
        od;
}
 
inline SiftDown(x) {
        ii = x;
        do
                :: 2 * ii + 1 >= m -> break;
                :: else ->
                        int j = ii;
                        if
                                :: a[2 * ii] < a[j] -> j = 2 * ii + 1;
                                :: else -> skip;
                        fi;
                        if
                                :: 2 * ii + 2 < m && a[2 * ii + 2] < a[j] -> j = 2 * ii + 2;
                                :: else -> skip;
                        fi;
                        if
                                :: ii == j -> break;
                                :: else -> skip;
                        fi;
                        int tmp2 = a[ii];
                        a[ii] = a[j];
                        a[j] = tmp2;
                        ii = j;
        od;
}
 
inline SiftUp(x) {
        ii = x;
        do
                :: ii <= 0 -> break;
                :: else ->
                        if
                                :: a[(ii - 1) / 2] > a[ii] ->
                                        int tmp2 = a[ii];
                                        a[ii] = a[(ii - 1) / 2];
                                        a[(ii - 1) / 2] = tmp2;
                                        ii = (ii - 1) / 2;
                                :: else -> break;
                        fi;
        od;
}
 
inline add(v) {
        adding = true;
        if
                :: !full ->    
                        atomic {
                                pm = m;
                                a[m] = v;
                                m++;
                                SiftUp(m - 1);
                                isHeap();
                                find(v);
                        }
                :: else -> skip;
        fi;
        adding = false;
}
 
inline extract() {
        extracting = true;
        if
                :: !empty ->
                        atomic {
                                pm = m;
                                res = a[0];
                                m--;
                                a[0] = a[m];
                                SiftDown(0);
                                isHeap();
                        }
                        extracting = false;
                :: else -> res = -1; skip;
        fi;
        extracting = false;
}
 
inline rand(x) {
        x = 0;
        select(x: 0..10)
}
 
active proctype Main() {
        m = 0;
        printf("started\n");
        do
                :: m > 0 ->
                        printf("add %d\n", m);
                        int v = 0;
                        rand(v);
                        printf("adding %d\n", v);
                        add(v);
                        printf("%d added\n", v);
                :: m == 0 ->
                        printf("finish %d\n", m);
                        break;
                :: else ->
                        printf("extract %d\n", m);
                        extract();
                        printf("%d extracted\n", res);
        od;
}
 
