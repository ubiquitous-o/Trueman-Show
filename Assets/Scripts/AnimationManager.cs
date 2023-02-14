using UnityEngine;

public class AnimationManager : MonoBehaviour
{
    private CharacterController characterController;
    private Animator animator;
    // Start is called before the first frame update
    void Start()
    {
        characterController = GetComponent<CharacterController>();
        animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.A)){
            animator.SetBool("isSit", true);
        }
        else if(Input.GetKey(KeyCode.S)){
            animator.SetBool("isWalk",true);
        }
        else if(Input.GetKey(KeyCode.D)){
            animator.SetBool("isStand", true);
        }
        
    }
}
