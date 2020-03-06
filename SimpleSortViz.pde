import java.util.*;
import java.lang.reflect.*;
import java.util.LinkedList;
int scl, w, pauseMS = 5;
int[] arr;
int items = 600;
boolean sort = false;
SortingAlgo sortingAlgorithm;
Scene currentScene;
int[] matchArr;
String[] sortAlgoArr = 
  new String[]{
  "Settings", "Random Inf.", 
  "BubbleSort", "InsertionSort", "SelectionSort", 
  "MergeSort", "HeapSort", "QuickSort", "ShellSort", 
  "CountingSort", "RadixSort", "BucketSort", "TimSort", 
  "CombSort", "PigeonholeSort", "CycleSort", "CocktailSort", 
  "StrandSort", "BitonicSort", "PancakeSort", "BinaryInsertionSort", 
  "BogoSort", "GnomeSort", "StoogeSort", "TreeSort", "OddEvenSort", "MergeSort3Way", 
  "StalinSort"
};

enum Settings {


  ITEMS("Set items"), SEED("Set seed"), RANDOM_SEED("Set random seed");
  private String name;
  private Settings(String name) {
    this.name = name;
  }
  public String getName() {
    return name;
  }
  public static Settings getType(String name) {
    for (Settings s : Settings.values()) {
      if (s.getName().equals(name)) return s;
    }
    return null;
  }
}
String[] settings;
HashMap<String, Object> settingsMap = new HashMap();

void setup() {
  size(1000, 800);
  //fullScreen();

  settings = new String[Settings.values().length+1];
  settings[0] = "Back";
  int i = 1;
  for (Settings s : Settings.values()) {
    settings[i++] = s.getName();
  }
  settingsMap.put(settings[1], 600);
  settingsMap.put(settings[2], 101010101010l);
  settingsMap.put(settings[3], null);

  //int items = (int) settingsMap.get(Settings.ITEMS.getName());
  if (items > width/2) {
    items = width/2;
    println("Limit hit, defaults to " + width/2);
  }

  reset();
  noLoop();
  currentScene = Scene.MENU;
}

enum Scene {
  MENU, 
    SORT, 
    INF_SORT, 
    SETTINGS
}

void reset() {
  List<Integer> sizeList = new ArrayList<Integer>();
  //int items = (int) settingsMap.get(Settings.ITEMS.getName());
  for (int i = 1; i < items+1; i++) {
    sizeList.add(i);
  }
  int maxHeight = sizeList.get(sizeList.size()-1);
  w = width/(sizeList.size());
  scl = height/maxHeight;

  matchArr = toIntArray(sizeList);
  arr = shuffleArray(sizeList);
  redIndex = -1;
  blueIndex = -1;
  greenIndex = -1;
  sorting = false;
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      if (currentScene == Scene.MENU)
        decSelect(sortAlgoArr);
      else if (currentScene == Scene.SETTINGS)
        decSelect(settings);
    } else if (keyCode == DOWN) {
      if (currentScene == Scene.MENU)
        incSelect(sortAlgoArr);
      else if (currentScene == Scene.SETTINGS)
        incSelect(settings);
    }
  } else if (keyCode == ENTER || key == ' ') {
    if (currentScene == Scene.MENU) {
      println(selectIndex);
      if (sortAlgoArr[selectIndex] == "Settings") {
        currentScene = Scene.SETTINGS;
        redraw();
      } else if (sortAlgoArr[selectIndex] == "Random Inf.") {
        currentScene = Scene.INF_SORT;
      } else {
        initClass(sortAlgoArr[selectIndex]);
        startAlgo();
      }
    } else if (currentScene == Scene.SETTINGS) {
      String menuItem = settings[selectIndex];
      if (menuItem == "Back")
        toMenu();
      if (menuItem == Settings.RANDOM_SEED.getName()) {
        println("new Random");
        Random r = new Random();
        settingsMap.put(menuItem, r.nextLong()); 
        redraw();
      }
    }
  } else if (key == 'r') {
    toMenu();
  }
}

void toMenu() {
  currentScene = Scene.MENU;
  reset();
  sort = false;
  redraw();
}

void initClass(String str) {
  try {
    Class<?> innerClass = Class.forName(this.getClass().getCanonicalName() + "$" + str);
    Constructor<?> ctor = innerClass.getDeclaredConstructor( this.getClass());
    sortingAlgorithm = (SortingAlgo) ctor.newInstance(this);
  } 
  catch (ClassNotFoundException e) {
    e.printStackTrace();
  } 
  catch (NoSuchMethodException e) {
    e.printStackTrace();
  } 
  catch (InvocationTargetException e) {
    e.printStackTrace();
  } 
  catch (InstantiationException e) {
    e.printStackTrace();
  } 
  catch (IllegalAccessException e) {
    e.printStackTrace();
  }
}

void startAlgo() {
  currentScene = Scene.SORT;
  redraw();
}

int selectIndex = 0;
void incSelect(Object[] arr) {
  if (selectIndex + 1 > arr.length-1) selectIndex = 0;
  else selectIndex++;
  redraw();
}

void decSelect(Object[] arr) {
  if (selectIndex - 1 < 0) selectIndex = arr.length-1;
  else selectIndex--;
  redraw();
}

void drawMenu() {
  for (int y = 0; y < sortAlgoArr.length; y++) {
    if (selectIndex == y) textSize(20);
    else textSize(12);
    text(sortAlgoArr[y], width/2, height/4+(y*20));
  }
}

void drawSettings() {
  for (int y = 0; y < settings.length; y++) {
    if (selectIndex == y) textSize(20);
    else textSize(12);
    String val = getVal(settings[y]);
    text((val.length()==0?"":val+" ") + settings[y], width/2, height/4+(y*20));
  }
}
//"Set items","Set seed"
String getVal(String str) {
  String val = "";
  Settings s = null;
  if (null == Settings.getType(str)) {
    s = Settings.getType(str);
  }
  if (s == null) return "";

  switch(s) {
    case ITEMS : 
      val = (String)settingsMap.get(str).toString();
    break;
    case SEED: 
      val = (String)settingsMap.get(str).toString();
    break;
  default:
    val = "";
  }
  return val;
}

void drawSortGraph() {
  for (int i = 0; i < arr.length-1; i++) {
    if (i == redIndex) fill(255, 0, 0);
    else if (i == blueIndex) fill(0, 0, 255);
    else if (i == greenIndex) fill(0, 255, 0);
    else fill(255);
    rect(i*w, height-(arr[i]*scl), w, (arr[i]*scl));
  }
}

int redIndex = -1;
int blueIndex = -1;
int greenIndex = -1;

boolean sorting = false;
void draw() {
  background(0);
  switch (currentScene) {
  case MENU:
    drawMenu();
    break;
  case SORT:
    sort = isSorted(arr);
    if (!sort && !sorting) {
      sorting = true;
      thread("sort");
    } else {
      redraw();
    }
    if (sort) {
      sorting = false;
    }
    drawSortGraph();
    break;
  case INF_SORT:
    //
    break;
  case SETTINGS:
    drawSettings();
    break;
  }
}

public void sort() {
  sortingAlgorithm.sort(arr);
}

public void step() {
  step(pauseMS, 0);
}

public void step(int ms) {
  step(ms, 0);
}

public void step(int ms, int ns) {
  try {
    redraw();
    Thread.sleep(ms, ns);
    redraw();
  } 
  catch (Exception x) {
    x.printStackTrace();
  }
}

public int[] toIntArray(List<Integer> list) {
  int[] ret = new int[list.size()];
  int i = 0;
  for (Integer e : list)  
    ret[i++] = e;
  return ret;
}

public List<Integer> toList(int[] list) {
  List ret = new ArrayList();
  for (int i = 0; i < list.length-1; i++) {
    ret.add(list[i]);
  }
  return ret;
}

public int[] shuffleArray(List<Integer> a) {
  List<Integer> b = new ArrayList<Integer>();
  Object l = (Object) Settings.SEED.getName();
  Random r = new Random((long)settingsMap.get(l));
  while (a.size() != 0) {
    int arrayIndex = (int) (r.nextFloat() * (a.size()));
    b.add(a.get(arrayIndex));
    a.remove(a.get(arrayIndex));
  }
  return toIntArray(b);
}

public boolean isSorted(int[] arr) {
  boolean sorted = true;
  for (int i = 0; i < arr.length-1; i++) {
    if (arr[i] != matchArr[i]) sorted = false;
  }
  return sorted;
}

interface SortingAlgo {
  boolean sort(int[] a);
}

//SORTING ALGORITHMS

class BubbleSort implements SortingAlgo {
  boolean sort(int[] a) {
    boolean sorted = false;
    int temp;
    while (!sorted) {
      sorted = true;
      for (int i = 0; i < a.length - 1; i++) {
        if (a[i] > a[i+1]) {
          redIndex = i;
          temp = a[i];
          a[i] = a[i+1];
          a[i+1] = temp;
          sorted = false;
        }
      }
      step();
    }
    return sorted;
  }
}

class InsertionSort implements SortingAlgo {
  boolean sort(int[] a) {
    for (int i = 1; i < a.length; i++) {
      int current = a[i];
      int j = i - 1;
      while (j >= 0 && current < a[j]) {
        a[j+1] = a[j];
        redIndex = j;
        j--; 
        step();
      }
      // at this point we've exited, so j is either -1
      // or it's at the first element where current >= a[j]
      a[j+1] = current;
      step();
    }
    step();
    return true;
  }
}

class SelectionSort implements SortingAlgo {
  boolean sort(int[] a) {
    for (int i = 0; i < a.length; i++) {
      int min = a[i];
      int minId = i;

      for (int j = i+1; j < a.length; j++) {
        if (a[j] < min) {
          min = a[j];
          minId = j;
        }
      }        

      // swapping
      int temp = a[i];
      redIndex = min;
      a[i] = min;
      a[minId] = temp;
      step();
    }
    step();
    return true;
  }
}

class MergeSort implements SortingAlgo {
  boolean sort(int[] a) {
    mergeSort(a, 0, a.length-1);
    step();
    return true;
  }

  void mergeSort(int[] array, int left, int right) {
    if (right <= left) return;
    int mid = (left+right)/2;
    mergeSort(array, left, mid);
    mergeSort(array, mid+1, right);
    merge(array, left, mid, right);
    step();
  }

  void merge(int[] array, int left, int mid, int right) {
    // calculating lengths
    int lengthLeft = mid - left + 1;
    int lengthRight = right - mid;

    // creating temporary subarrays
    int leftArray[] = new int [lengthLeft];
    int rightArray[] = new int [lengthRight];

    // copying our sorted subarrays into temporaries
    for (int i = 0; i < lengthLeft; i++)
      leftArray[i] = array[left+i];
    for (int i = 0; i < lengthRight; i++)
      rightArray[i] = array[mid+i+1];

    // iterators containing current index of temp subarrays
    int leftIndex = 0;
    int rightIndex = 0;

    // copying from leftArray and rightArray back into array
    for (int i = left; i < right + 1; i++) {
      // if there are still uncopied elements in R and L, copy minimum of the two
      if (leftIndex < lengthLeft && rightIndex < lengthRight) {
        if (leftArray[leftIndex] < rightArray[rightIndex]) {
          array[i] = leftArray[leftIndex];
          leftIndex++;
        } else {
          array[i] = rightArray[rightIndex];
          rightIndex++;
        }
      }
      // if all the elements have been copied from rightArray, copy the rest of leftArray
      else if (leftIndex < lengthLeft) {
        array[i] = leftArray[leftIndex];
        leftIndex++;
      }
      // if all the elements have been copied from leftArray, copy the rest of rightArray
      else if (rightIndex < lengthRight) {
        array[i] = rightArray[rightIndex];
        rightIndex++;
      }
    }
    step();
  }
}


class HeapSort implements SortingAlgo {
  boolean sort(int[] a) {
    heapSort(a);
    step();
    return true;
  }

  void heapSort(int[] array) {
    if (array.length == 0) return;

    // Building the heap
    int length = array.length;
    // we're going from the first non-leaf to the root
    for (int i = length / 2-1; i >= 0; i--)
      heapify(array, length, i);

    for (int i = length-1; i >= 0; i--) {
      int temp = array[0];
      array[0] = array[i];
      array[i] = temp;

      heapify(array, i, 0);
    }
  }

  void heapify(int[] array, int length, int i) {
    int leftChild = 2*i+1;
    int rightChild = 2*i+2;
    int largest = i;

    // if the left child is larger than parent
    if (leftChild < length && array[leftChild] > array[largest]) {
      largest = leftChild;
    }

    // if the right child is larger than parent
    if (rightChild < length && array[rightChild] > array[largest]) {
      largest = rightChild;
    }

    // if a swap needs to occur
    if (largest != i) {
      int temp = array[i];
      array[i] = array[largest];
      array[largest] = temp;
      heapify(array, length, largest);
      step();
    }
  }
}

class QuickSort implements SortingAlgo {
  boolean sort(int[] a) {
    quickSort(a, 0, a.length-1);
    step();
    return true;
  }

  int partition(int[] array, int begin, int end) {
    int pivot = end;

    int counter = begin;
    for (int i = begin; i < end; i++) {        
      if (array[i] < array[pivot]) {
        int temp = array[counter];
        array[counter] = array[i];
        array[i] = temp;
        redIndex = i;
        counter++;  
        step();
      }
    }
    greenIndex = counter;
    blueIndex = pivot;
    int temp = array[pivot];
    array[pivot] = array[counter];
    array[counter] = temp;

    return counter;
  }

  void quickSort(int[] array, int begin, int end) {
    if (end <= begin) return;
    int pivot = partition(array, begin, end);
    quickSort(array, begin, pivot-1);
    quickSort(array, pivot+1, end);
  }
}

class ShellSort implements SortingAlgo {
  boolean sort(int[] array) {
    // first part uses the Knuth's interval sequence
    int h = 1;
    while (h <= array.length / 3) {
      h = 3 * h + 1; // h is equal to highest sequence of h<=length/3
      // (1,4,13,40...)
    }

    // next part
    while (h > 0) { // for array of length 10, h=4
      // This step is similar to insertion sort below
      for (int i = 0; i < array.length; i++) {

        int temp = array[i];
        int j;

        for (j = i; j > h - 1 && array[j - h] >= temp; j = j - h) {
          array[j] = array[j - h];
          step();
        }
        array[j] = temp;
      }
      h = (h - 1) / 3;
    }
    return true;
  }
}

class CountingSort implements SortingAlgo {
  boolean sort(int[] arr) {
    int max = Arrays.stream(arr).max().getAsInt(); 
    int min = Arrays.stream(arr).min().getAsInt(); 
    int range = max - min + 1; 
    int count[] = new int[range]; 
    int output[] = new int[arr.length]; 
    for (int i = 0; i < arr.length; i++)  
    { 
      count[arr[i] - min]++; 
      redIndex = i;
      step();
    } 

    for (int i = 1; i < count.length; i++)  
    { 
      count[i] += count[i - 1];
      redIndex = i;
      step();
    } 

    for (int i = arr.length - 1; i >= 0; i--)  
    { 
      output[count[arr[i] - min] - 1] = arr[i]; 
      count[arr[i] - min]--; 
      redIndex = i;
      step();
    } 

    for (int i = 0; i < arr.length; i++) 
    { 
      arr[i] = output[i]; 
      redIndex = i;
      step();
    }
    return true;
  }
}

class RadixSort implements SortingAlgo {
  boolean sort(int[] arr) {
    radixsort(arr, arr.length);
    return true;
  }

  int getMax(int arr[], int n) { 
    int mx = arr[0]; 
    for (int i = 1; i < n; i++) 
      if (arr[i] > mx) 
        mx = arr[i]; 
    return mx;
  } 

  void radixsort(int arr[], int n) { 
    // Find the maximum number to know number of digits 
    int m = getMax(arr, n); 

    // Do counting sort for every digit. Note that instead 
    // of passing digit number, exp is passed. exp is 10^i 
    // where i is current digit number 
    for (int exp = 1; m/exp > 0; exp *= 10) {
      countSort(arr, n, exp);
    }
  }

  void countSort(int arr[], int n, int exp) { 
    int output[] = new int[n]; // output array 
    int i; 
    int count[] = new int[10]; 
    Arrays.fill(count, 0); 

    // Store count of occurrences in count[] 
    for (i = 0; i < n; i++) {
      count[ (arr[i]/exp)%10 ]++;
    }  

    // Change count[i] so that count[i] now contains 
    // actual position of this digit in output[] 
    for (i = 1; i < 10; i++) {
      count[i] += count[i - 1];
    }

    // Build the output array 
    for (i = n - 1; i >= 0; i--) 
    { 
      output[count[ (arr[i]/exp)%10 ] - 1] = arr[i]; 
      count[ (arr[i]/exp)%10 ]--; 
      redIndex = count[ (arr[i]/exp)%10 ] - 1;
      blueIndex = i;
      step();
    } 

    // Copy the output array to arr[], so that arr[] now 
    // contains sorted numbers according to curent digit 
    for (i = 0; i < n; i++) {
      arr[i] = output[i];
      blueIndex = i;
      step();
    }
  }
}

class BucketSort implements SortingAlgo {
  boolean sort(int[] arr) {
    bucketSort(arr);
    return true;
  }

  void bucketSort(int[] input) {
    // get hash codes
    final int[] code = hash(input);

    // create and initialize buckets to ArrayList: O(n)
    List[] buckets = new List[code[1]];
    for (int i = 0; i < code[1]; i++) {
      buckets[i] = new ArrayList();
      redIndex = i;
      step();
    }

    // distribute data into buckets: O(n)
    for (int i : input) {
      buckets[hash(i, code)].add(i);
      redIndex = i;
      step();
    }

    // sort each bucket O(n)
    for (List bucket : buckets) {
      Collections.sort(bucket);
      step();
    }

    int ndx = 0;
    // merge the buckets: O(n)
    for (int b = 0; b < buckets.length; b++) {
      for (Object v : buckets[b]) {
        input[ndx++] = (int)v;
        redIndex = b;
        step();
      }
    }
  }

  private int[] hash(int[] input) {
    int m = input[0];
    for (int i = 1; i < input.length; i++) {
      if (m < input[i]) {
        m = input[i];
        redIndex = i;
      }
    }
    return new int[] { m, (int) Math.sqrt(input.length) };
  }

  private int hash(int i, int[] code) {
    return (int) ((double) i / code[0] * (code[1] - 1));
  }
}

class TimSort implements SortingAlgo {
  int RUN = 32; 
  boolean sort(int[] arr) {
    timSort(arr, arr.length);
    return true;
  }

  // this function sorts array from left index to  
  // to right index which is of size atmost RUN  
  void insertionSort(int[] arr, int left, int right)  
  { 
    for (int i = left + 1; i <= right; i++)  
    { 
      int temp = arr[i]; 
      int j = i - 1; 
      while (arr[j] > temp && j >= left) 
      { 
        arr[j + 1] = arr[j]; 
        j--;
      } 
      arr[j + 1] = temp;
    }
  } 

  // merge function merges the sorted runs  
  void merge(int[] arr, int l, int m, int r) 
  { 
    // original array is broken in two parts  
    // left and right array  
    int len1 = m - l + 1, len2 = r - m; 
    int[] left = new int[len1]; 
    int[] right = new int[len2]; 
    for (int x = 0; x < len1; x++)  
    { 
      left[x] = arr[l + x];
    } 
    for (int x = 0; x < len2; x++)  
    { 
      right[x] = arr[m + 1 + x];
    } 

    int i = 0; 
    int j = 0; 
    int k = l; 

    // after comparing, we merge those two array  
    // in larger sub array  
    while (i < len1 && j < len2)  
    { 
      if (left[i] <= right[j])  
      { 
        arr[k] = left[i]; 
        i++;
      } else 
      { 
        arr[k] = right[j]; 
        j++;
      } 
      k++;
    } 

    // copy remaining elements of left, if any  
    while (i < len1) 
    { 
      arr[k] = left[i]; 
      k++; 
      i++;
    } 

    // copy remaining element of right, if any  
    while (j < len2)  
    { 
      arr[k] = right[j]; 
      k++; 
      j++;
    }
  } 

  // iterative Timsort function to sort the  
  // array[0...n-1] (similar to merge sort)  
  void timSort(int[] arr, int n)  
  { 

    // Sort individual subarrays of size RUN  
    for (int i = 0; i < n; i += RUN)  
    { 
      insertionSort(arr, i, Math.min((i + 31), (n - 1)));
    } 

    // start merging from size RUN (or 32). It will merge  
    // to form size 64, then 128, 256 and so on ....  
    for (int size = RUN; size < n; size = 2 * size)  
    { 

      // pick starting point of left sub array. We  
      // are going to merge arr[left..left+size-1]  
      // and arr[left+size, left+2*size-1]  
      // After every merge, we increase left by 2*size  
      for (int left = 0; left < n; left += 2 * size)  
      { 

        // find ending point of left sub array  
        // mid+1 is starting point of right sub array  
        int mid = left + size - 1; 
        int right = Math.min((left + 2 * size - 1), (n - 1)); 

        // merge sub array arr[left.....mid] &  
        // arr[mid+1....right]  
        merge(arr, left, mid, right);
      }
    }
  }
}

class CombSort implements SortingAlgo {
  boolean sort(int[] arr) {
    combsort(arr);
    return true;
  }
  // To find gap between elements 
  int getNextGap(int gap) 
  { 
    // Shrink gap by Shrink factor 
    gap = (gap*10)/13; 
    if (gap < 1) 
      return 1; 
    return gap;
  } 

  // Function to sort arr[] using Comb Sort 
  void combsort(int arr[]) 
  { 
    int n = arr.length; 

    // initialize gap 
    int gap = n; 

    // Initialize swapped as true to make sure that 
    // loop runs 
    boolean swapped = true; 

    // Keep running while gap is more than 1 and last 
    // iteration caused a swap 
    while (gap != 1 || swapped == true) 
    { 
      // Find next gap 
      gap = getNextGap(gap); 

      // Initialize swapped as false so that we can 
      // check if swap happened or not 
      swapped = false; 

      // Compare all elements with current gap 
      for (int i=0; i<n-gap; i++) 
      { 
        if (arr[i] > arr[i+gap]) 
        { 
          // Swap arr[i] and arr[i+gap] 
          int temp = arr[i]; 
          arr[i] = arr[i+gap]; 
          arr[i+gap] = temp; 

          // Set swapped 
          swapped = true;
        } 
        step(0, 10);
      }
    }
  }
}

class PigeonholeSort implements SortingAlgo {
  boolean sort(int[] arr) {
    pigeonhole_sort(arr, arr.length);
    return true;
  }

  void pigeonhole_sort(int arr[], int n) 
  { 
    int min = arr[0]; 
    int max = arr[0]; 
    int range, i, j, index;  

    for (int a=0; a<n; a++) 
    { 
      if (arr[a] > max) 
        max = arr[a]; 
      if (arr[a] < min) 
        min = arr[a]; 

      redIndex = a;
      step();
    } 

    range = max - min + 1; 
    int[] phole = new int[range]; 
    Arrays.fill(phole, 0); 

    for (i = 0; i<n; i++) {
      phole[arr[i] - min]++; 
      redIndex = range-i;
      step();
    }

    index = 0; 

    for (j = 0; j<range; j++) 
      while (phole[j]-->0) {
        arr[index++]=j+min; 
        redIndex = j;
        step();
      }
  }
}

class CycleSort implements SortingAlgo {
  boolean sort(int[] arr) {
    cycleSort(arr, arr.length);
    return true;
  }

  void cycleSort(int arr[], int n) { 
    // count number of memory writes 
    int writes = 0; 

    // traverse array elements and put it to on 
    // the right place 
    for (int cycle_start = 0; cycle_start <= n - 2; cycle_start++) { 
      // initialize item as starting point 
      int item = arr[cycle_start]; 

      // Find position where we put the item. We basically 
      // count all smaller elements on right side of item. 
      int pos = cycle_start; 
      for (int i = cycle_start + 1; i < n; i++) 
        if (arr[i] < item) {
          pos++;
        }

      // If item is already in correct position 
      if (pos == cycle_start) 
        continue; 

      // ignore all duplicate elements 
      while (item == arr[pos]) 
        pos += 1; 

      // put the item to it's right position 
      if (pos != cycle_start) { 
        int temp = item; 
        item = arr[pos]; 
        arr[pos] = temp; 
        writes++;
      } 

      // Rotate rest of the cycle 
      while (pos != cycle_start) { 
        pos = cycle_start; 

        // Find position where we put the element 
        for (int i = cycle_start + 1; i < n; i++) {
          if (arr[i] < item) 
            pos += 1;
        }

        // ignore all duplicate elements 
        while (item == arr[pos]) 
          pos += 1; 

        // put the item to it's right position 
        if (item != arr[pos]) { 
          int temp = item; 
          item = arr[pos]; 
          arr[pos] = temp; 
          writes++;
        }
        step();
      }
    }
  }
}

class CocktailSort implements SortingAlgo {
  boolean sort(int[] arr) {
    cocktailSort(arr);
    return true;
  }

  void cocktailSort(int a[]) { 
    boolean swapped = true; 
    int start = 0; 
    int end = a.length; 

    while (swapped == true) { 
      // reset the swapped flag on entering the 
      // loop, because it might be true from a 
      // previous iteration. 
      swapped = false; 

      // loop from bottom to top same as 
      // the bubble sort 
      for (int i = start; i < end - 1; ++i) { 
        if (a[i] > a[i + 1]) { 
          int temp = a[i]; 
          a[i] = a[i + 1]; 
          a[i + 1] = temp; 
          swapped = true;
        }
      } 

      // if nothing moved, then array is sorted. 
      if (swapped == false) 
        break; 

      // otherwise, reset the swapped flag so that it 
      // can be used in the next stage 
      swapped = false; 

      // move the end point back by one, because 
      // item at the end is in its rightful spot 
      end = end - 1; 
      step(30);

      // from top to bottom, doing the 
      // same comparison as in the previous stage 
      for (int i = end - 1; i >= start; i--) { 
        if (a[i] > a[i + 1]) { 
          int temp = a[i]; 
          a[i] = a[i + 1]; 
          a[i + 1] = temp; 
          swapped = true;
        }
      } 

      // increase the starting point, because 
      // the last stage would have moved the next 
      // smallest number to its rightful spot. 
      start = start + 1;
    }
  }
}

/*
class StrandSort implements SortingAlgo{
 boolean sort(int[] arr) {
 List list = Arrays.asList(toObject(arr));
 ArrayDeque ad = new ArrayDeque(list);
 strandSort(ad,new ArrayDeque());
 return true;
 }
 
 void strandSort(ArrayDeque<Integer> unSortArr, ArrayDeque sortArr){
 //Base case
 if(unSortArr.size() > 1){
 return;
 }
 
 ArrayDeque<Integer> sublist = new ArrayDeque();
 sublist.addLast(unSortArr.getFirst());
 unSortArr.pop();
 
 for(Integer it : unSortArr){
 if(it > sublist.getLast()){
 sublist.addLast(it);
 unSortArr.remove(it);
 } else continue;
 }
 
 sortArr.add(sublist);
 
 strandSort(unSortArr,sortArr);
 }
 
 public Integer[] toObject(int[] intArray) {
 
 Integer[] result = new Integer[intArray.length];
 for (int i = 0; i < intArray.length; i++) {
 result[i] = Integer.valueOf(intArray[i]);
 }
 return result;
 }
 }
 */

class BitonicSort implements SortingAlgo {
  boolean sort(int[] arr) {
    int up = 1;
    sort(arr, arr.length, up);
    return true;
  }

  /* The parameter dir indicates the sorting direction, 
   ASCENDING or DESCENDING; if (a[i] > a[j]) agrees 
   with the direction, then a[i] and a[j] are 
   interchanged. */
  void compAndSwap(int a[], int i, int j, int dir) 
  { 
    if ( (a[i] > a[j] && dir == 1) || 
      (a[i] < a[j] && dir == 0)) 
    { 
      // Swapping elements 
      int temp = a[i]; 
      a[i] = a[j]; 
      a[j] = temp;
    }
  } 

  /* It recursively sorts a bitonic sequence in ascending 
   order, if dir = 1, and in descending order otherwise 
   (means dir=0). The sequence to be sorted starts at 
   index position low, the parameter cnt is the number 
   of elements to be sorted.*/
  void bitonicMerge(int a[], int low, int cnt, int dir) 
  { 
    if (cnt>1) 
    { 
      int k = cnt/2; 
      for (int i=low; i<low+k; i++) 
        compAndSwap(a, i, i+k, dir); 
      bitonicMerge(a, low, k, dir); 
      bitonicMerge(a, low+k, k, dir);
    } 
    step(0, 1);
  } 

  /* This funcion first produces a bitonic sequence by 
   recursively sorting its two halves in opposite sorting 
   orders, and then  calls bitonicMerge to make them in 
   the same order */
  void bitonicSort(int a[], int low, int cnt, int dir) 
  { 
    if (cnt>1) 
    { 
      int k = cnt/2; 

      // sort in ascending order since dir here is 1 
      bitonicSort(a, low, k, 1); 

      // sort in descending order since dir here is 0 
      bitonicSort(a, low+k, k, 0); 

      // Will merge wole sequence in ascending order 
      // since dir=1. 
      bitonicMerge(a, low, cnt, dir);
    }
  } 

  /*Caller of bitonicSort for sorting the entire array 
   of length N in ASCENDING order */
  void sort(int a[], int N, int up) 
  { 
    bitonicSort(a, 0, N, up);
  }
}

class PancakeSort implements SortingAlgo {
  boolean sort(int[] arr) {
    pancakeSort(arr, arr.length);
    return true;
  }
  /* Reverses arr[0..i] */
  void flip(int arr[], int i) 
  { 
    int temp, start = 0; 
    while (start < i) 
    { 
      temp = arr[start]; 
      arr[start] = arr[i]; 
      arr[i] = temp; 
      start++; 
      i--; 
      step();
    }
  } 

  // Returns index of the  
  // maximum element in  
  // arr[0..n-1]  
  int findMax(int arr[], int n) 
  { 
    int mi, i; 
    for (mi = 0, i = 0; i < n; ++i) 
      if (arr[i] > arr[mi]) 
        mi = i; 
    return mi;
  } 

  // The main function that 
  // sorts given array using  
  // flip operations 
  int pancakeSort(int arr[], int n) 
  { 
    // Start from the complete 
    // array and one by one 
    // reduce current size by one 
    for (int curr_size = n; curr_size > 1; --curr_size) 
    { 
      // Find index of the 
      // maximum element in 
      // arr[0..curr_size-1] 
      int mi = findMax(arr, curr_size); 

      // Move the maximum element 
      // to end of current array 
      // if it's not already at  
      // the end 
      if (mi != curr_size-1) 
      { 
        // To move at the end, 
        // first move maximum 
        // number to beginning 
        flip(arr, mi); 

        // Now move the maximum  
        // number to end by 
        // reversing current array 
        flip(arr, curr_size-1); 
        //step();
      }
    } 

    return 0;
  }
}

class BinaryInsertionSort implements SortingAlgo {
  boolean sort(int[] array) {
    for (int i = 1; i < array.length; i++) 
    { 
      int x = array[i]; 

      // Find location to insert using binary search 
      int j = Math.abs(Arrays.binarySearch(array, 0, i, x) + 1); 

      //Shifting array to one location right 
      System.arraycopy(array, j, array, j+1, i-j); 

      //Placing element at its correct location 
      array[j] = x; 
      step();
    }
    return true;
  }
}

class BogoSort implements SortingAlgo {
  boolean sort(int[] arr) {
    bogoSort(arr);
    return true;
  }
  // Sorts array a[0..n-1] using Bogo sort 
  void bogoSort(int[] a) 
  { 
    // if array is not sorted then shuffle the 
    // array again 
    while (isSortedBogo(a) == false) 
      shuffle(a);
  } 

  // To generate permuatation of the array 
  void shuffle(int[] a) 
  { 
    // Math.random() returns a double positive 
    // value, greater than or equal to 0.0 and 
    // less than 1.0. 
    for (int i=1; i <= a.length-1; i++) 
      swap(a, i, (int)(Math.random()*i));
    step();
  } 

  // Swapping 2 elements 
  void swap(int[] a, int i, int j) 
  { 
    int temp = a[i]; 
    a[i] = a[j]; 
    a[j] = temp;
  } 

  // To check if array is sorted or not 
  boolean isSortedBogo(int[] a) 
  { 
    for (int i=1; i<a.length; i++) 
      if (a[i] < a[i-1]) 
        return false; 
    step();
    return true;
  }
}

class GnomeSort implements SortingAlgo {
  boolean sort(int[] arr) {
    gnomeSort(arr, arr.length);
    return true;
  }

  void gnomeSort(int arr[], int n) 
  { 
    int index = 0; 

    while (index < n) { 
      if (index == 0) 
        index++; 
      if (arr[index] >= arr[index - 1]) 
        index++; 
      else { 
        int temp = 0; 
        temp = arr[index]; 
        arr[index] = arr[index - 1]; 
        arr[index - 1] = temp; 
        index--;
      }
      if (index%50==0)step();
    } 

    return;
  }
}

class StoogeSort implements SortingAlgo {
  boolean sort(int[] arr) {
    stoogesort(arr, 0, arr.length-1);
    return true;
  }

  void stoogesort(int arr[], int l, int h) { 
    if (l >= h) 
      return; 

    // If first element is smaller 
    // than last, swap them 
    if (arr[l] > arr[h]) { 
      int t = arr[l]; 
      arr[l] = arr[h]; 
      arr[h] = t; 
      if (t%4==0)step();
      redIndex = arr[l];
      blueIndex = arr[h];
    } 

    // If there are more than 2 elements in 
    // the array 
    if (h - l + 1 > 2) { 
      int t = (h - l + 1) / 3; 

      // Recursively sort first 2/3 elements 
      stoogesort(arr, l, h - t); 

      // Recursively sort last 2/3 elements 
      stoogesort(arr, l + t, h); 

      // Recursively sort first 2/3 elements 
      // again to confirm 
      stoogesort(arr, l, h - t); 
      if (t%4==0)step(0, 1);
    }
  }
}

class TreeSort implements SortingAlgo {
  boolean sort(int[] arr) {
    this.treeins(arr);
    this.inorderRec(this.root);
    return true;
  }
  class Node  
  { 
    int key; 
    Node left, right; 

    public Node(int item)  
    { 
      key = item; 
      left = right = null;
    }
  } 

  // Root of BST 
  Node root; 

  int counter = 0;
  // Constructor 
  TreeSort()  
  {  
    root = null;
  } 

  // This method mainly 
  // calls insertRec() 
  void insert(int key) 
  { 
    root = insertRec(root, key);
  }
  /* A recursive function to  
   insert a new key in BST */
  Node insertRec(Node root, int key)  
  { 

    /* If the tree is empty, 
     return a new node */
    if (root == null)  
    { 
      root = new Node(key); 
      return root;
    } 

    /* Otherwise, recur 
     down the tree */
    if (key < root.key) 
      root.left = insertRec(root.left, key); 
    else if (key > root.key) 
      root.right = insertRec(root.right, key); 

    /* return the root */
    return root;
  } 

  // A function to do  
  // inorder traversal of BST 
  void inorderRec(Node root)  
  { 
    if (root != null)  
    { 
      inorderRec(root.left); 
      //System.out.print(root.key + " "); 
      arr[counter++] = root.key;
      inorderRec(root.right); 
      step();
    }
  } 
  void treeins(int arr[]) 
  { 
    for (int i = 0; i < arr.length; i++) 
    { 
      insert(arr[i]); 
      redIndex = i;
      step();
    }
  }
}

class OddEvenSort implements SortingAlgo {
  boolean sort(int[] arr) {
    int n = arr.length-1;
    boolean isSorted = false; // Initially array is unsorted 

    while (!isSorted) 
    { 
      isSorted = true; 
      int temp =0; 

      // Perform Bubble sort on odd indexed element 
      for (int i=1; i<=n-2; i=i+2) 
      { 
        if (arr[i] > arr[i+1]) 
        { 
          temp = arr[i]; 
          arr[i] = arr[i+1]; 
          arr[i+1] = temp; 
          isSorted = false;
        }
      } 

      // Perform Bubble sort on even indexed element 
      for (int i=0; i<=n-2; i=i+2) 
      { 
        if (arr[i] > arr[i+1]) 
        { 
          temp = arr[i]; 
          arr[i] = arr[i+1]; 
          arr[i+1] = temp; 
          isSorted = false;
        } 
        if (i % 10 == 0) step(0, 1);
      }
    } 
    return isSorted;
  }
}

class MergeSort3Way implements SortingAlgo {
  Integer[] iarr;
  boolean sort(int[] arr) {
    iarr = toObject(arr);
    mergeSort3Way(iarr);
    return true;
  }

  Integer[] toObject(int[] intArray) {

    Integer[] result = new Integer[intArray.length];
    for (int i = 0; i < intArray.length; i++) {
      result[i] = Integer.valueOf(intArray[i]);
    }
    return result;
  }

  int[] toPrimitive(Integer[] IntegerArray) {

    int[] result = new int[IntegerArray.length];
    for (int i = 0; i < IntegerArray.length; i++) {
      result[i] = IntegerArray[i].intValue();
    }
    return result;
  }

  void updateArray() {
    arr = toPrimitive(iarr);
    step();
  }

  void mergeSort3Way(Integer[] gArray) 
  { 
    // if array of size is zero returns null 
    if (gArray == null) 
      return; 

    // creating duplicate of given array 
    Integer[] fArray = new Integer[gArray.length]; 

    // copying alements of given array into 
    // duplicate array 
    for (int i = 0; i < fArray.length; i++) 
      fArray[i] = gArray[i]; 

    // sort function 
    mergeSort3WayRec(fArray, 0, gArray.length, gArray); 

    // copy back elements of duplicate array 
    // to given array 
    for (int i = 0; i < fArray.length; i++) {
      gArray[i] = fArray[i]; 
      updateArray();
    }
  } 

  /* Performing the merge sort algorithm on the 
   given array of values in the rangeof indices 
   [low, high).  low is minimum index, high is 
   maximum index (exclusive) */
  void mergeSort3WayRec(Integer[] gArray, 
    int low, int high, Integer[] destArray) 
  { 
    // If array size is 1 then do nothing 
    if (high - low < 2) 
      return; 

    // Splitting array into 3 parts 
    int mid1 = low + ((high - low) / 3); 
    int mid2 = low + 2 * ((high - low) / 3) + 1; 

    // Sorting 3 arrays recursively 
    mergeSort3WayRec(destArray, low, mid1, gArray); 
    mergeSort3WayRec(destArray, mid1, mid2, gArray); 
    mergeSort3WayRec(destArray, mid2, high, gArray); 

    // Merging the sorted arrays 
    merge(destArray, low, mid1, mid2, high, gArray);
    updateArray();
  } 

  /* Merge the sorted ranges [low, mid1), [mid1, 
   mid2) and [mid2, high) mid1 is first midpoint 
   index in overall range to merge mid2 is second 
   midpoint index in overall range to merge*/
  void merge(Integer[] gArray, int low, 
    int mid1, int mid2, int high, 
    Integer[] destArray) 
  { 
    int i = low, j = mid1, k = mid2, l = low; 

    // choose smaller of the smallest in the three ranges 
    while ((i < mid1) && (j < mid2) && (k < high)) 
    { 
      if (gArray[i].compareTo(gArray[j]) < 0) 
      { 
        if (gArray[i].compareTo(gArray[k]) < 0) 
          destArray[l++] = gArray[i++]; 

        else
          destArray[l++] = gArray[k++];
      } else
      { 
        if (gArray[j].compareTo(gArray[k]) < 0) 
          destArray[l++] = gArray[j++]; 
        else
          destArray[l++] = gArray[k++];
      }
    } 

    // case where first and second ranges have 
    // remaining values 
    while ((i < mid1) && (j < mid2)) 
    { 
      if (gArray[i].compareTo(gArray[j]) < 0) 
        destArray[l++] = gArray[i++]; 
      else
        destArray[l++] = gArray[j++];
    } 

    // case where second and third ranges have 
    // remaining values 
    while ((j < mid2) && (k < high)) 
    { 
      if (gArray[j].compareTo(gArray[k]) < 0) 
        destArray[l++] = gArray[j++]; 

      else
        destArray[l++] = gArray[k++];
    } 

    // case where first and third ranges have 
    // remaining values 
    while ((i < mid1) && (k < high)) 
    { 
      if (gArray[i].compareTo(gArray[k]) < 0) 
        destArray[l++] = gArray[i++]; 
      else
        destArray[l++] = gArray[k++];
    } 

    // copy remaining values from the first range 
    while (i < mid1) 
      destArray[l++] = gArray[i++]; 

    // copy remaining values from the second range 
    while (j < mid2) 
      destArray[l++] = gArray[j++]; 

    // copy remaining values from the third range 
    while (k < high) 
      destArray[l++] = gArray[k++];
  }
}

import static java.util.Collections.emptyList;
class StalinSort implements SortingAlgo {
  boolean sort(int[] arr) {
    s(toList(arr),arr);
    step();
    return true;
  }

  <T extends Comparable<T>> List<Integer> s(List<Integer> list,int[] array) {
    List<Integer> sorted = new ArrayList();
    Integer max = null;
    for (Integer candidate : list) {
      if (sorted.isEmpty() || candidate.compareTo(max) >= 0) {
        sorted.add(candidate);
        max = candidate;
      }
      array = toArray(list);
      step();  
    }
    return sorted;
  }
}

int[] toArray(List l){
    int[] arr = new int[l.size()];
    for (int i = 0; i < l.size(); i++) {
        arr[i] = (int)l.get(i);
    }
    return arr;
}

class TEMPLATE_SORT2 implements SortingAlgo {
  boolean sort(int[] arr) {
    return true;
  }
}
