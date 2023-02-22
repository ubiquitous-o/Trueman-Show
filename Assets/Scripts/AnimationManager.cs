using UnityEngine;
using UnityEngine.AI;

public class AnimationManager : MonoBehaviour
{
    [SerializeField]
    private GameObject bedPosition;
    [SerializeField]
    private GameObject sofaSitPosition;
    [SerializeField]
    private GameObject floorSitPosition;
    [SerializeField]
    private GameObject bikePosition;


    [SerializeField]
    private Transform defaultPos;

    // private Transform targetPos;
    private NavMeshAgent agent;

    private float agentSpeed;
    private Animator animator;

    bool isStand;
    // bool isWalk;
    private enum GOALS{
        DEFAULT,FLOOR,BED,SOFA,BIKE
    }
    private GOALS goals;

    // Start is called before the first frame update
    void Start()
    {
        isStand = true;
        goals = GOALS.DEFAULT;
        agent = GetComponent<NavMeshAgent>();
        animator = GetComponent<Animator>();
    }
    void Update(){
        // if(animator.GetFloat("WalkSpeed") > 0.1){
        //     isWalk = true;
        // }
        // else{
        //     isWalk = false;
        // }
        animator.SetFloat("WalkSpeed", agent.velocity.sqrMagnitude);
    }
    // private void OnAnimatorIK()
    // {
    //     if(isWalk){
    //         animator.SetLookAtWeight(0.2f, 0.3f, 1f, 0f, 0.5f);     // LookAtの調整
    //         animator.SetLookAtPosition(targetPos.position);
    //     }
        
    // }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Goal"){
            Debug.Log("goal");
            switch(goals){
                case GOALS.FLOOR:
                    animator.SetTrigger("SitFloor");
                    Debug.Log("arrive");
                    floorSitPosition.SetActive(false);
                    break;
                case GOALS.BED:
                    animator.SetTrigger("Sleep");
                    bedPosition.SetActive(false);
                    Debug.Log("arrive");
                    break;
                case GOALS.SOFA:
                    animator.SetTrigger("SitChair");
                    sofaSitPosition.SetActive(false);
                    Debug.Log("arrive");
                    break;
                case GOALS.BIKE:
                    animator.SetTrigger("Bike");
                    bikePosition.SetActive(false);
                    Debug.Log("arrive");
                    break;
                default:

                    break;
            }

        }
        
    }

    public void Stand(){
        if(!isStand){
            isStand = true;
            animator.SetTrigger("Idle");
        }
    }
    public void SitFloor(){
        if(isStand){
            isStand = false;
            floorSitPosition.SetActive(true);
            goals = GOALS.FLOOR;
            // targetPos = floorSitPosition.transform;
            agent.SetDestination(floorSitPosition.transform.position);
        }
     }
    public void SitSofa(){
        if(isStand){
            isStand = false;
            sofaSitPosition.SetActive(true);
            goals = GOALS.SOFA;
            // targetPos = sofaSitPosition.transform;
            agent.SetDestination(sofaSitPosition.transform.position);
        }
    }
    public void LieBed(){
        if(isStand){
            isStand = false;
            bedPosition.SetActive(true);
            goals = GOALS.BED;
            // targetPos = bedPosition.transform;
            agent.SetDestination(bedPosition.transform.position);

        }
    }
    public void Bike(){
        if(isStand){
            isStand = false;
            bikePosition.SetActive(true);
            goals = GOALS.BIKE;
            // targetPos = bikePosition.transform;
            agent.SetDestination(bikePosition.transform.position);
        }
    }
}
