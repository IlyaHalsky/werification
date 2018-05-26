
/*  
 *  Алгоритм Форда - Фалкерсона для поиска максимального потока в транспортной сети.
 *  
 *  Транспортная сеть задается числом узлов N (2 <= N <= MAX_N) и набором ребер 
 *  с указанием пропускной способности каждого существующего ребра C (0 <= C <= MAXC). 
 *  Если пропускная способность ребра равна 0, то ребра нет.
 *
 *  Поток ищется между источником S (вершина с номером 0), и стоком T (вершина с номером N-1).
 *
 *  Идея алгоритма заключается в итеративном увеличении потока с 0 до максимально возможного. На каждой итерации ищется путь,
 *  по которому можно пустить дополнительный поток из источника в сток.
 *  Алгоритм работает за время O(E * f), где E - число ребер, f - максимальный поток в сети.
 */

#define MAX_N 3		// maximum vertex count
#define MAX_M 3		// maximum number of edges
#define MAXC 3		// maximum edge constraint

// algorithm states:
#define UNKNOWN					0
#define SEARCHING_PATH			1
#define SEARCHING_FINISHED		2
#define CALCULATING_INC_VALUE	3
#define CALCULATING_FINISHED	4
#define INCREASING_FLOW			5
#define INCREASING_FINISHED		6
#define ALGORITHM_FINISHED		7


typedef array {
	int a[MAX_N];
}


byte state;		// current state

int n;			// states' count

array c[MAX_N];	// edge constrains
array f[MAX_N];	// edge flow

bool foundPath; 
int incFlowValue;
int maxFlow;

int pi;					// path index
int path[MAX_N];		// for path saving
bool visited[MAX_N];	// is vertex x visited?


/* ------------------------------- auxiliary "functions" -------------------------------- */

int minValue;

inline min(a, b) {
	if
	:: (a < b)	->
		minValue = a;
	:: else		->
		minValue = b;
	fi;
}

int randomValue;

// generate random in range [minV, maxV]
inline genRandom(minV, maxV) {
	randomValue = minV;
	do
	:: (randomValue == maxV)		->
		break;	// increased up to max value -> stop
	:: else						->
		if
		:: randomValue++;	// randomly increment
		:: break;			// or stop
		fi;
	od;
}


/* ------------------------------- algorithm "functions" -------------------------------- */

int i, j;	// temp variables


inline findPathImpl() {
	// clearing
	for (i : 0..(n-1)) {
		visited[i] = false;
	}

	foundPath = false;	
	pi = 0;
	path[pi] = 0;	// starting from source
	bool findNext;
	
	// searching...
	do
	:: ((!foundPath) && (pi >= 0))	->
		if
		:: (!visited[path[pi]])		->	// going forward
			visited[path[pi]] = true;
			if 
			:: (path[pi] == n - 1)	->	foundPath = true;
			:: else					->	path[pi+1] = 0;	// new search
			fi;
		:: else						->	// continuing search
			path[pi+1]++;
		fi;
	
		if 
		:: (!foundPath)		->	
			pi++;
			findNext = false;
			do
			:: ((path[pi] < n) && (!findNext))	->
				i = path[pi - 1];
				j = path[pi];
				if 
				:: ((c[i].a[j] - f[i].a[i] > 0) && (!visited[j]))	->
					findNext = true;
				:: else 	->
					path[pi]++;
				fi;
			:: else 			->	break;
			od;
			if
			:: (!findNext)	->	pi = pi - 2;
			:: else			->	skip;
			fi;
		:: else		->	skip;
		fi;
	:: else		-> break;
	od;
}


inline findPath() {
	state = SEARCHING_PATH;
	findPathImpl();
	state = SEARCHING_FINISHED;
}


int pi2;

inline calculateIncreaseValue() {
	state = CALCULATING_INC_VALUE;
	
	incFlowValue = 2 * MAXC;
	pi2 = 0;
	do
	:: (pi2 < pi) 	->
		i = path[pi2];
		j = path[pi2 + 1];
		
		min(incFlowValue, c[i].a[j] - f[i].a[j]);
		incFlowValue = minValue;
		
		pi2++;
	:: else 		->	break;
	od;
		
	state = CALCULATING_FINISHED;
}

inline increaseFlow() {
	state = INCREASING_FLOW;

	pi2 = 0;
	do
	:: (pi2 < pi) 	->
		i = path[pi2];
		j = path[pi2 + 1];

		f[i].a[j] = f[i].a[j] + incFlowValue;
		f[j].a[i] = f[j].a[i] - incFlowValue;

		pi2++;
	:: else 		->	break;
	od;
	maxFlow = maxFlow + incFlowValue;

	state = INCREASING_FINISHED;
}	


inline findMaxFlow() {
	maxFlow = 0;

	findPath();
	do
	:: (foundPath)	->
		calculateIncreaseValue();
		increaseFlow();
		
		findPath();
	:: else 		->	break;
	od;
	
	state = ALGORITHM_FINISHED;
}


init {
	printf("INIT: Starting\n\n");
	
	printf("Generating input:\n");

	genRandom(2, MAX_N);
	n = randomValue;
	genRandom(0, MAX_M);
	int m = randomValue;
	printf("Vertex count = %d\n", n);
	printf("Edges (count = %d):\n", m);
	int en, cc;
	for (en : 0..(m-1)) {
		genRandom(0, n - 1);
		i = randomValue;
		genRandom(0, n - 1);
		j = randomValue;
		genRandom(1, MAXC);
		cc = randomValue;
		printf("%d -> %d, c = %d\n", i, j, cc);
		c[i].a[j] = cc;
	}
	printf("\n");
	
	printf("Starting algorithm...\n");
	findMaxFlow();
	printf("Finished. Max flow = %d\n\n", maxFlow);
	
	findPathImpl();
	
	printf("INIT: Finished\n");
}

