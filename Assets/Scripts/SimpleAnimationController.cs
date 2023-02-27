using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleAnimationController : MonoBehaviour
{


    [Button("Stand")]
    public bool standButton;
    [Button("Sofa")]
    public bool sofaButton;
//     [Button("Bed")]
//     public bool bedButton;
    [Button("Floor1")]
    public bool floorButton;
    [Button("Floor2")]
    public bool bikeButton;
    

    [SerializeField]
    GameObject avator;
    AnimationManager animationManager;
    FaceController faceController;

    // Start is called before the first frame update
    void Start()
    {
        animationManager = avator.GetComponent<AnimationManager>();
        faceController = avator.GetComponent<FaceController>();
    }

    public void Stand(){
            animationManager.Stand();
    }
    public void Sofa(){
            animationManager.SitSofa();
    }
//     public void Bed(){
//            animationManager.LieBed();
//     }
    public void Floor1(){
            animationManager.SitFloor();
    }
    public void Floor2(){
            animationManager.Bike();
    }
}
