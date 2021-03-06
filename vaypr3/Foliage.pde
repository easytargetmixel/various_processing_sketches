class Foliage {

  /*
   * Static Finals
   */

  private static final int roundsPerDrawCall = 8;

  private static final int NUM_OF_INITIAL_NODES = 128;

  private static final int MAX_AGE = 128;

  private static final int ADD_NODE_ROUND_LIMIT = 4;

  private static final int MAX_NUM_OF_NODES = 512;

  /*
   * Attributes
   */

  private FoliageNode firstNode;

  private int numOfNodes = 0;
  
  private int nodeAddCounter = 0;

  private float displaySize = max(width, height);

  private float jitter = displaySize * 0.001f;

  private float nodeDensity = (int) (NUM_OF_INITIAL_NODES / 16f);

  private boolean stopped = false;

  private int age = 0;

  private float startX = width / 2f; // + random(width * 0.33f);

  private float startY = height / 2f;

  /*
   * Initialization
   */

  public Foliage() {
    //mJitter = mDisplaySize * 0.002f;
  }

  public Foliage initCircle() {

    final int numberOfCircles = (int) random(5) + 1;

    FoliageNode lastNode = null;
    for (int c = 0; c < numberOfCircles; c++) {

      final float circleCenterX =startX + (getJitter() * 10f);
      final float circleCenterY = startY + (getJitter() * 10f);
      final float radius = random(displaySize * 0.01f) + displaySize * 0.001f;
      final float squeezeFactor = random(0.66f) + 0.66f;

      for (int i = 0; i < NUM_OF_INITIAL_NODES; i++) {

        final float angleOfNode = TWO_PI * ((i + 1f) / NUM_OF_INITIAL_NODES);
        final PVector vector = new PVector();

        vector.x = circleCenterX
          + ((cos(angleOfNode) * radius) * squeezeFactor)
          + getJitter();
        vector.y = circleCenterY
          + (sin(angleOfNode) * radius)
          + getJitter();
        //vector.z = 0f;

        final FoliageNode node = new FoliageNode(vector);

        if (firstNode == null) {
          firstNode = node;
          lastNode = node;
        } else if (i == NUM_OF_INITIAL_NODES - 1) {
          //mPreferredNeighbourDistance = node.distanceToNode(lastNode);
          lastNode.next = node;
          node.next = firstNode;
        } else {
          lastNode.next = node;
          lastNode = node;
        }
        
        ++numOfNodes;
      }
    }

    return this;
  }

  Foliage initLine() {
    //mDrawBezier = true;

    FoliageNode lastNode = null;

    for (int i = 0; i < NUM_OF_INITIAL_NODES; i++) {

      final PVector vector = new PVector();
      vector.x = ((float) i / (float) NUM_OF_INITIAL_NODES * width) + getJitter();
      vector.y = startY + getJitter();
      //vector.z = 0f;

      final FoliageNode node = new FoliageNode(vector);

      if (firstNode == null) {
        firstNode = node;
        lastNode = node;
      } else if (i == NUM_OF_INITIAL_NODES - 1) {
        //mPreferredNeighbourDistance = node.distanceToNode(lastNode);
        lastNode.next = node;
      } else {
        lastNode.next = node;
        lastNode = node;
      }
      
      ++numOfNodes;
    }

    return this;
  }

  /*
   * Lifecycle
   */

  public boolean drawIfAlive(final color c) {

    if (numOfNodes >= MAX_NUM_OF_NODES && ++age >= MAX_AGE) {
      return false;
    }

    stopped = false;

    noFill();
    stroke(c);
    strokeWeight(4f);
    nodeAddCounter = 0;
    
    for (int i = 0; i < roundsPerDrawCall; i++) {
      drawAndUpdateNodes();
    }
    return true;
  }

  private void drawAndUpdateNodes() {
    int nodeCounter = 0;
    FoliageNode currentNode = firstNode.next;
    FoliageNode nextNode;

    beginShape();
    do {
      nextNode = currentNode.next;
      if (nextNode == null) {
        break;
      }

      //drawAndUpdateNode(currentNode);
      currentNode.update();
      vertex(
        currentNode.vector.x, 
        currentNode.vector.y, 
        currentNode.vector.z
        );

      if (
        nodeAddCounter < ADD_NODE_ROUND_LIMIT
        && numOfNodes < MAX_NUM_OF_NODES
        && (nodeCounter % nodeDensity == 0)
        ) {
        addNodeNextTo(currentNode);
        ++nodeAddCounter;
      }

      currentNode = nextNode;
      ++nodeCounter;
    } while (!stopped && currentNode != firstNode);
    endShape();

    drawSecondShape();
    
    //println("" + numOfNodes);
  }

  private void drawSecondShape() {
    FoliageNode currentNode = firstNode;
    FoliageNode nextNode;

    beginShape();
    do {
      nextNode = currentNode.next;
      if (nextNode == null) {
        break;
      }

      vertex(
        currentNode.vector.x - width / 5f, 
        currentNode.vector.y, 
        currentNode.vector.z
        );

      currentNode = nextNode;
    } while (!stopped && currentNode != firstNode);
    endShape();
  }

  //private void drawAndUpdateNode(final FoliageNode node) {
  //  node.update();

  //  point(
  //    node.vector.x, 
  //    node.vector.y, 
  //    node.vector.z
  //    );

  //  point(
  //    node.vector.x - width / 4f, 
  //    node.vector.y, 
  //    node.vector.z
  //    );
  //}

  private void addNodeNextTo(final FoliageNode node) {
    final FoliageNode oldNeighbour = node.next;
    if (oldNeighbour == null) {
      return;
    }

    final FoliageNode newNeighbour = new FoliageNode();

    newNeighbour.vector = PVector.add(node.vector, oldNeighbour.vector).mult(0.5f);

    node.next = newNeighbour;
    newNeighbour.next = oldNeighbour;
    
    ++numOfNodes;
  }

  public void stopPerforming() {
    stopped = true;
  }

  private float getJitter() {
    return jitter * 0.5f - random(jitter);
  }
}
