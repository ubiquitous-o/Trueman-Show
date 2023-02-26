using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraLookAt : MonoBehaviour
{
    [SerializeField]
    private GameObject target;

    // Update is called once per frame
    void Update()
    {
        float speed = 0.1f;
        Vector3 relativePos = target.transform.position - this.transform.position;
        Quaternion rotation = Quaternion.LookRotation (relativePos);
        transform.rotation  = Quaternion.Slerp (this.transform.rotation, rotation, speed);
 
    }
}
