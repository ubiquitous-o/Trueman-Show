using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleAnimationController : MonoBehaviour
{


    [Button("Stand")]
    public bool standButton;
    [Button("Sofa")]
    public bool sofaButton;
    [Button("Bed")]
    public bool bedButton;
    [Button("Floor")]
    public bool floorButton;
    [Button("Bike")]
    public bool bikeButton;
    

    [SerializeField]
    GameObject avator;
    AnimationManager animationManager;
    

    // Start is called before the first frame update
    void Start()
    {
        animationManager = avator.GetComponent<AnimationManager>();
    }

    public void Stand(){
            animationManager.Stand();
    }
    public void Sofa(){
            animationManager.SitSofa();
    }
    public void Bed(){
           animationManager.LieBed();
    }
    public void Floor(){
            animationManager.SitFloor();
    }
    public void Bike(){
            animationManager.Bike();
    }
}
