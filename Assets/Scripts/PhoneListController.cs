using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public sealed class PhoneListController
{
    private IReadOnlyList<string> _labelTexts;
    private readonly VisualTreeAsset _elementTemplate;
    private readonly ListView _chatList;

    public PhoneListController(VisualElement root, VisualTreeAsset elementTemplate, List<string> labelTexts){
        _chatList = root.Q<ListView>("ChatList");
        _elementTemplate = elementTemplate;
        
        _chatList.makeItem = () =>{
            var element = _elementTemplate.Instantiate();
            var chatController = new PhoneChatController(element);
            element.userData = chatController;
            return element;
        };
        _chatList.bindItem = (item, index) =>{
            var controller = (PhoneChatController)item.userData;
            controller.SetText(labelTexts[index]);

        };

        // _chatList.fixedItemHeight =120;
        _chatList.itemsSource = labelTexts;

    }
}
