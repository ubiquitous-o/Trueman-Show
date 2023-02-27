using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniVRM10;
using DG.Tweening;

public class FaceController : MonoBehaviour
{
    Vrm10Instance vrm;
    bool isBusy = false;


    float blinkDuration;
    
    float blinkInterval;

    bool blinking = false;
    WaitForSeconds blinkDurationWait;
    WaitForSeconds blinkIntervalWait;

    bool happying = false;
    float happyDuration;
    WaitForSeconds happyDurationWait;

    bool relaxing = false;
    float relaxDuration;
    WaitForSeconds relaxDurationWait;


    bool IsActive { get; set; } = true;
    ExpressionPreset currentPreset;

    float happyTime = 7.0f;
    float relaxTime = 3.0f;

    void Start(){
        vrm = GetComponent<Vrm10Instance>();
        currentPreset = ExpressionPreset.neutral;
        InitFace(0);

    }
    void Update()
    {
        if (!IsActive)
        {
            return;
        }
        Blink();
        happyTime -= Time.deltaTime;
        relaxTime -= Time.deltaTime;
        if(happyTime < 0.0f){
            happyTime = 7.0f;
            var ratio = Random.Range(0,10);
            if(ratio <= 0){
                Happy();
            }
        }
        if(relaxTime < 0.0f){
            relaxTime = 3.0f;
            var ratio = Random.Range(0,10);
            if(ratio <= 1){
                Relaxed();
            }
        }

    }

    private void Happy(){
        if(happying){
            return;
        }
        StartCoroutine(HappyTimer());
    }
    private void Relaxed(){
        if(relaxing){
            return;
        }
        StartCoroutine(RelaxTimer());
    }

    private void Blink()
    {
        if (blinking)
        {
            return;
        }
        StartCoroutine(BlinkTimer());
    }

    IEnumerator RelaxTimer()
    {
        relaxing = true;

        relaxDuration = Random.Range(0.0f,0.7f);
        relaxDurationWait = new WaitForSeconds(relaxDuration);


        ChangeFace(ExpressionPreset.relaxed, 0, relaxDuration, relaxDuration);
        yield return relaxDurationWait;
        yield return null;
        ChangeFace(ExpressionPreset.relaxed, relaxDuration,0, relaxDuration);
        yield return relaxDurationWait;

        relaxing = false;
    }
    IEnumerator HappyTimer()
    {
        happying = true;

        happyDuration = Random.Range(2,5);
        happyDurationWait = new WaitForSeconds(happyDuration);


        ChangeFace(ExpressionPreset.happy, 0, 1, happyDuration);
        yield return happyDurationWait;
        yield return null;
        ChangeFace(ExpressionPreset.happy, 1,0, happyDuration);
        yield return happyDurationWait;

        happying = false;
    }
    IEnumerator BlinkTimer()
    {
        blinking = true;

        blinkInterval = Random.Range(4,10);
        blinkIntervalWait = new WaitForSeconds(blinkInterval);

        blinkDuration = Random.Range(0.2f,0.5f);
        blinkDurationWait = new WaitForSeconds(blinkDuration);


        ChangeFace(ExpressionPreset.blink, 0, 1, blinkDuration);
        yield return blinkDurationWait;
        yield return null;
        ChangeFace(ExpressionPreset.blink, 1,0,blinkDuration);
        yield return blinkDurationWait;
        yield return blinkIntervalWait;

        blinking = false;
    }

    private void InitFace(float duration)
    {
        ChangeFace(ExpressionPreset.neutral, 0, 1, duration);
    }
    private void ChangeFace(ExpressionPreset preset, float startValue, float endValue, float duration, Ease ease = Ease.InOutQuad)
    {
        if (isBusy)
        {
            return;
        }

        isBusy = true;

        startValue = Mathf.Clamp01(startValue);
        endValue = Mathf.Clamp01(endValue);

        UpdateFace(currentPreset, 0);
        float progress = startValue;
        DOTween.To(() => progress, x => progress = x, endValue, duration).OnUpdate(() => { UpdateFace(preset, progress); isBusy = false; }).SetEase(ease);


        currentPreset = preset;
    }
    void UpdateFace(ExpressionPreset nextPreset, float progress)
    {
        vrm.Runtime.Expression.SetWeight(ExpressionKey.CreateFromPreset(nextPreset), progress);
    }
}