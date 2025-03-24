<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 모두싸인연관팝업 > 비대면요청 팝업
-- 작성자 : 이강원
-- 최초 작성일 : 2023-04-21 16:20:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    
    var submitType = ""; // 파일 첨부 타입

    $(document).ready(function () {
      var hpNo = "${inputParam.hp_no}";
      var confirmMsg = `${inputParam.confirm_msg}`;
      $M.setValue("hp_no", hpNo.replaceAll("-", ""));
      $M.setValue("confirm_msg", confirmMsg == '' ? "발송하시겠습니까?" : confirmMsg);
      $M.setValue("target_type", ${inputParam.target_type_cm eq 'M'} ? "직원" : "고객");
    });

    // 문서발송
    function goSend() {
      var sendCd = $M.getValue("modusign_send_cd");
      var sendValue = "";

      if (sendCd == "") {
        alert($M.setValue("target_type") + " 수신방법은 필수 입력입니다.");
        return;
      }

      // 고객발송인 경우 체크
      if (${inputParam.target_type_cm ne 'M'}) {
        if($M.getValue('send_cust_name') == '') {
          alert("고객/회사명은 필수 값입니다.");
          return;
        }
      }

      var msg = "";
      if (sendCd == "EMAIL") {
        sendValue = $M.getValue("send_email");
        msg = "고객 수신방법이 이메일인 경우 이메일은 필수 입력 입니다."
      } else if (sendCd == "KAKAO") {
        sendValue = $M.getValue("send_hp_no");
        msg = "고객 수신방법이 카카오톡인 경우 번호는 필수 입력 입니다."
      }

      if (sendValue == "") {
        alert(msg);
        return;
      }

      // 운송자 전송 옵션 true
      var isTrans = $M.getValue("is_trans");
      let transSendName = $M.getValue("trans_send_name");
      let transSenHpNo = $M.getValue("trans_send_hp_no");
      let transSendCarNo = $M.getValue("trans_car_no");
      let signFileSeq = $M.getValue("sign_file_seq");

      if(isTrans === 'true') {
        if(transSendName === '') {
          alert("운송자명은 필수 입력 입니다.")
          return;
        }
        
        if(transSenHpNo === '') {
          alert("운송자핸드폰은 필수 입력 입니다.")
          return;
        }
        
        if(transSendCarNo === '') {
          alert("운송자차량번호은 필수 입력 입니다.")
          return;
        }
      }

      var param = {
        "modusign_send_cd": sendCd,
        "modusign_send_value": sendValue,
        "cust_name": $M.getValue("send_cust_name"),
        "mem_name": $M.getValue("mem_name"),
        
        "trans_send_name": transSendName,
        "trans_send_hp_no": transSenHpNo,
        "trans_send_car_no": transSendCarNo,
        "sign_file_seq": signFileSeq,
      }

      var confirmMsg = $M.getValue("confirm_msg");
      if(confirm(confirmMsg)) {
        try{
          opener.${inputParam.parent_js_name}(param);
          window.close();
        } catch(e) {
          console.log(e);
          alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
        }
      }
    }

    // 고객구분변경
    function fnChangeGubun() {
      if("CUST" == $M.getValue("cust_gubun")) {
        $("#cust_name").removeClass("dpn");
        $("hp_no").removeClass("dpn");
        $("#breg_name").addClass("dpn");
        $("breg_hp_no").addClass("dpn");
        $M.setValue("send_cust_name", $M.getValue("cust_name"));
      } else {
        $("#cust_name").addClass("dpn");
        $("hp_no").addClass("dpn");
        $("#breg_name").removeClass("dpn");
        $("breg_hp_no").removeClass("dpn");
        $M.setValue("send_cust_name", $M.getValue("breg_name"));
      }
    }

    //팝업 닫기
    function fnClose() {
      window.close();
    }

    function fnLayerImage(fileSeq) {
      var params = {
        file_seq : fileSeq
      };

      var popupOption = "";
      $M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
    }

    // 파일첨부팝업
    function goFileUploadPopup(type) {
      var param = {
        upload_type : 'SIGN',
        file_type : 'both',
        file_ext_type : 'img',
        max_size : 3000
      }
      submitType = type;
      openFileUploadPanel('fnSetFile', $M.toGetParam(param));
    }

    // 파일세팅
    function fnSetFile(file) {
      var str = '';
      str += '<div class="table-attfile-item submit_' + submitType + '">';
      str += '<a href="javascript:fnLayerImage(' + file.file_seq + ');">' + file.file_name + '</a>&nbsp;';
      str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'' +  submitType + '\')"><i class="material-iconsclose font-18 text-default"></i></button>';
      str += '</div>';
      
      $M.setValue('sign_file_seq', file.file_seq);
      $('.submit_'+submitType+'_div').append(str);
      $("#btn_submit_"+submitType).remove();
    }

    // 파일삭제
    function fnRemoveFile(type) {
      var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
      if (result) {
        $(".submit_" + type).remove();
        var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\''+type+'\')" id="btn_submit_'+type+'">파일찾기</button>'
        $('.submit_'+type+'_div').append(str);

        $M.setValue('sign_file_seq', '0');
      } else {
        return false;
      }
    }

  </script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form" style="height : 100%">
  <input type="hidden" name="send_cust_name" value="${inputParam.cust_name}">
  <input type="hidden" name="is_trans" value="${inputParam.is_trans}">
  <input type="hidden" name="target_type" value="">
  <!-- 팝업 -->
  <div class="popup-wrap width-100per" style="height : 100%">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <div class="content-wrap">
      <c:if test="${inputParam.is_trans eq 'true'}">
        <div class="title-wrap mt10">
          <h4>운송자수신방법</h4>
        </div>
        <table class="table-border mt5">
          <colgroup>
            <col width="120px">
            <col width="">
          </colgroup>
          <tbody>
          <tr>
            <th class="text-right">운송자이름</th>
            <td>
              <input type="text" class="form-control" id="trans_send_name" name="trans_send_name" value="${transInfoMap.trans_send_name}">
            </td>
          </tr>
          <tr>
            <th class="text-right">운송자핸드폰</th>
            <td>
              <input type="text" class="form-control" id="trans_send_hp_no" name="trans_send_hp_no" format="phone" maxlength="11" value="${transInfoMap.trans_send_hp_no eq '' ? inputParam.trans_send_hp_no : transInfoMap.trans_send_hp_no}">
            </td>
          </tr>
          <tr>
            <th class="text-right">운송자차량번호</th>
            <td>
              <input type="text" class="form-control" id="trans_car_no" name="trans_car_no" value="${transInfoMap.trans_car_no}">
            </td>
          </tr>
          <tr>
            <th class="text-right">운송자서명</th>
            <td>
              <div class="table-attfile submit_sign_file_div">
                <c:if test="${transInfoMap.sign_file_seq ne '0'}">
                  <div class="submit_sign_file">
                    <a href="javascript:fnLayerImage(${transInfoMap.sign_file_seq})">${transInfoMap.sign_file_name}</a>
                    <input type="hidden" name="sign_file_seq" value="${transInfoMap.sign_file_seq}"/>
                    <button type="button" class="btn-default" onclick="javascript:fnRemoveFile('sign_file')">
                      <i class="material-iconsclose font-18 text-default"></i>
                    </button>
                  </div>
                </c:if>
                <c:if test="${transInfoMap.sign_file_seq eq '0'}">
                  <button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('sign_file')" id="btn_submit_sign_file">파일찾기</button>
                </c:if>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </c:if>
      <div class="title-wrap mt10">
        <h4>${inputParam.target_type_cm eq 'M'? '직원' : '고객'}수신방법</h4>
      </div>
      <table class="table-border mt5">
        <colgroup>
          <col width="120px">
          <col width="">
        </colgroup>
        <tbody>
          <c:if test="${inputParam.target_type_cm ne 'M'}">
          <tr>
            <th class="text-right">구분</th>
            <td>
              <div class="form-check form-check-inline">
                <input class="form-checck-input" type="radio" id="cust_gubun_cust" name="cust_gubun" value="CUST" checked="checked" onchange="fnChangeGubun()">
                <label for="cust_gubun_cust" class="form-check-label">고객명</label>
                <input class="form-checck-input" type="radio" id="cust_gubun_breg" name="cust_gubun" value="BREG" onchange="fnChangeGubun()">
                <label for="cust_gubun_breg" class="form-check-label">회사명</label>
              </div>
            </td>
          </tr>
          </c:if>
          <tr>
            <c:choose>
              <c:when test="${inputParam.target_type_cm eq 'M'}">
                <th class="text-right">직원명</th>
                <td>
                  <input type="text" class="form-control" id="mem_name" name="mem_name" value="${inputParam.mem_name}" readonly>
                </td>
              </c:when>
              <c:otherwise>
                <th class="text-right">고객/회사명</th>
                <td>
                  <input type="text" class="form-control" id="cust_name" name="cust_name" value="${inputParam.cust_name}" readonly>
                  <input type="text" class="form-control dpn" id="breg_name" name="breg_name" value="${inputParam.breg_name}" readonly>
                </td>
              </c:otherwise>
            </c:choose>
          </tr>
          <tr>
            <th class="text-right">
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="modusign_send_kakao" name="modusign_send_cd" value="KAKAO" checked="checked">
                <label for="modusign_send_kakao" class="form-check-label">카카오톡</label>
              </div>
            </th>
            <td>
              <input type="text" class="form-control" id="send_hp_no" name="send_hp_no" format="phone" maxlength="11" value="${inputParam.hp_no}">
            </td>
          </tr>
          <tr>
            <th class="text-right">
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" id="modusign_send_email" name="modusign_send_cd" value="EMAIL">
                <label for="modusign_send_email" class="form-check-label">이메일</label>
              </div>
            </th>
            <td>
              <input type="text" class="form-control" id="send_email" name="send_email" maxlength="50" value="${inputParam.email}">
            </td>
          </tr>
        </tbody>
      </table>
      <div class="btn-group mt5">
        <div class="right">
          <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
        </div>
      </div>
    </div>
  </div>
  <!-- /팝업 -->
</form>
</body>
</html>
