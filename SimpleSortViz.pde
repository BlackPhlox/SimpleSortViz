import java.util.*;
int scl,w;
int items = 600;
static int pauseMS = 5;
int[] arr;
boolean sort = false;
SortingAlgo sortingAlgorithm;
int[] matchArr;

void setup(){
  size(1000,800);
  if(items > width/2) {items = width/2;println("Limit hit, defaults to " + width/2);}
  reset();
  noLoop();
}

void reset(){
  List<Integer> sizeList = new ArrayList<Integer>();
  for(int i = 1; i < items+1; i++){
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

void keyPressed(){
  if(key == 'b'){
    startAlgo(new BubbleSort());
  } else if (key == 'i'){
    startAlgo(new InsertionSort());
  } else if (key == 's'){
    startAlgo(new SelectionSort());
  } else if (key == 'm'){
    startAlgo(new MergeSort());
  } else if (key == 'h'){
    startAlgo(new HeapSort());
  } else if (key == 'q'){
    startAlgo(new QuickSort());
  } else if (key == 'r'){
    startScreen = true;
    reset();
    sort = false;
    redraw();
  }
}

void startAlgo(SortingAlgo a){
  println(a.getClass().getName());
  sortingAlgorithm = a;
  startScreen = false;
  redraw();
}

int redIndex = -1;
int blueIndex = -1;
int greenIndex = -1;
boolean startScreen = true;
boolean sorting = false;
void draw(){
  background(0);
  if(startScreen){
    text("B:BubbleSort\nI:InsertionSort\nS:SelectionSort\nM:MergeSort\nH:HeapSort\nQ:QuickSort",width/2,height/2);
  } else {
    sort = isSorted(arr);
    if(!sort && !sorting){
      sorting = true;
      thread("sort");
    } else {
      redraw();
    }
    if(sort){
      sorting = false;
    }
  
    for(int i = 0; i < arr.length-1 ; i++){
      if(i == redIndex) fill(255,0,0);
      else if (i == blueIndex) fill(0,0,255);
      else if (i == greenIndex) fill(0,255,0);
      else fill(255);
      rect(i*w,height-(arr[i]*scl), w,(arr[i]*scl));
    }
  }
}

public void sort(){
  sortingAlgorithm.sort(arr);
}

public void step(){
  step(pauseMS);
}

public void step(int ms){
  try{
    redraw();
    Thread.sleep(ms);
    redraw();
  } catch (Exception x){
    x.printStackTrace();
  }  
}

public int[] toIntArray(List<Integer> list)  {
    int[] ret = new int[list.size()];
    int i = 0;
    for (Integer e : list)  
        ret[i++] = e;
    return ret;
}

public int[] shuffleArray(List<Integer> a) {
    List<Integer> b = new ArrayList<Integer>();
    while (a.size() != 0) {
        int arrayIndex = (int) (Math.random() * (a.size()));
        b.add(a.get(arrayIndex));
        a.remove(a.get(arrayIndex));
    }
    return toIntArray(b);
}

public boolean isSorted(int[] arr){
  boolean sorted = true;
  for(int i = 0; i < arr.length-1; i++){
    if(arr[i] != matchArr[i]) sorted = false;
  }
  return sorted;
}

interface SortingAlgo{
  boolean sort(int[] a);
}

class BubbleSort implements SortingAlgo{
  boolean sort(int[] a) {
    boolean sorted = false;
    int temp;
    if(!sorted){
      sorted = true;
      for (int i = 0; i < a.length - 1; i++) {
        if (a[i] > a[i+1]) {
            redIndex = i;
            temp = a[i];
            a[i] = a[i+1];
            a[i+1] = temp;
            sorted = false;
            step();
        }
      }
    }
    step();
    return sorted;
  }
}

class InsertionSort implements SortingAlgo{
  boolean sort(int[] a) {
    for (int i = 1; i < a.length; i++) {
        int current = a[i];
        int j = i - 1;
        while(j >= 0 && current < a[j]) {
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

class SelectionSort implements SortingAlgo{
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

class MergeSort implements SortingAlgo{
  boolean sort(int[] a) {
    mergeSort(a,0,a.length-1);
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
            }
            else {
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


class HeapSort implements SortingAlgo{
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

class QuickSort implements SortingAlgo{
  boolean sort(int[] a) {
    quickSort(a,0,a.length-1);
    step();
    return true;
  }
  
  int median2(int a, int b, int c) {
    return (a > b) ^ (a > c) ? a : (a > b) ^ (b > c) ? c : b;
  }
  
  int partition(int[] array, int begin, int end) {
    int elementCount= Math.floorDiv((end-begin), 2);
    int first = array[begin];
    int middle = array[begin+elementCount];
    int last = array[end];
    int pivot = median2(first, middle, last); 
    pivot = first;
    
    blueIndex = pivot;

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
    
    /*if(pivot == first){
      int temp = array[pivot];
      array[pivot] = array[begin];
      array[begin] = temp;
    }
    else if (pivot==middle) {
      int temp = array[pivot];
      array[pivot] = array[begin+elementCount];
      array[begin+elementCount] = temp;
    }
    else {*/
      int temp = array[pivot];
      array[pivot] = array[end];
      array[end] = temp;
    //}
    
    
    return counter;
  }

  void quickSort(int[] array, int begin, int end) {
      if (end <= begin) return;
      int pivot = partition(array, begin, end);
      quickSort(array, begin, pivot-1);
      quickSort(array, pivot+1, end);
  }
}
