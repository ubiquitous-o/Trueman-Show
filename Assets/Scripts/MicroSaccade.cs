using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MicroSaccade : MonoBehaviour
{
    // 振幅: 1度以下
    // 運動にかかる時間: 25ms程度
    // 平均速度: 10deg/sec
    // 頻度: 1~3Hz

    float duration = 0.025f;
    float time = 1.0f;

    WaitForSeconds saccadeDuration;


    // Update is called once per frame
    void Update()
    {
        time -= Time.deltaTime;
        if(time < 0.0f){
            time = Random.Range(1.0f,3.0f);
            StartCoroutine(Saccade());
        }

    }
    IEnumerator Saccade(){
        duration = Random.Range(duration-0.03f, duration+0.03f);
        saccadeDuration = new WaitForSeconds(duration);

        var movement_x = Random.Range(-0.05f, 0.05f);
        var movement_y = Random.Range(-0.05f, 0.05f);
        var movement_z = Random.Range(-0.05f, 0.05f);


        this.transform.position = new Vector3(this.transform.position.x + movement_x,this.transform.position.y + movement_y, this.transform.position.z + movement_z);
        
        yield return saccadeDuration;

        this.transform.position = new Vector3(this.transform.position.x - movement_x,this.transform.position.y - movement_y ,this.transform.position.z-movement_z);
    }
}
