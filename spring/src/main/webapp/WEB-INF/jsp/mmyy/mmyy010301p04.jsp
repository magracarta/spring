<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > 업무일지(일반) > 일정등록/상세
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-02-23 14:21:18
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

      let date = ${date};
      let listCnt = ${size};
      let planList = ${list};
      let workDt = '${inputParam.s_work_dt}';

      $(document).ready(function () {

        date = date.toString();
        const viewDate = date.substring(0, 4) + "-" + date.substring(4, 6) + "-" + date.substring(6);
        $("#view_date").append(viewDate).append("일 일정");

        fnInitPlanList(planList);
      });

      // 일정 목록 초기화
      function fnInitPlanList(list) {
        let innerHtml = '';

        if (listCnt > 0) {
          for (let i = 1; i <= listCnt; i++) {
            // for (let i=listCnt; i>0; i--) {
            innerHtml += fnMakeRow(i, list[i - 1]);
          }
        } else {
          listCnt = 1;
          innerHtml += fnMakeRow(1);
        }

        document.getElementById("planList").innerHTML = innerHtml;
        $(".calDate").datepicker();
        pageInit();
      }

      // 저장
      function goSave(alertYn) {
        let saveList = [];
        let validResult = true;

        $('tr[id^="tr_plan"]').each(function (index) {
          let data = {};
          const tr = $(this);
          const td = tr.children();

          data.work_plan_seq = td.find('[id^="work_plan_seq"]').val();
          data.plan_text = td.find('[id^="plan_text"]').val().trim();
          data.use_yn = td.find('[id^="use_yn"]').val();
          data.plan_dt = date;
          data.plan_st_dt = td.find('[id^="s_start"]').val().replace(/-/g, "");
          data.plan_ed_dt = td.find('[id^="s_end"]').val().replace(/-/g, "");

          // 등록정보가 없으면 신규
          if (data.work_plan_seq == 0) {
            data.cmd = "C";
          } else {
            data.cmd = "U";
          }

          if (!data.plan_text) {
            alert("일정에는 빈칸이 올 수 없습니다.");
            validResult = false;
            return false;
          }

          if (!data.plan_st_dt) {
            alert("시작날짜 에는 빈칸이 올 수 없습니다.");
            validResult = false;
            return false;
          }

          if (!data.plan_ed_dt) {
            alert("종료날짜 에는 빈칸이 올 수 없습니다.");
            validResult = false;
            return false;
          }

          saveList.push(data);
        });

        if (!validResult) return false;

        if (saveList.length === 0) {
          alert("수정한 내용이 없습니다.");
          return false;
        }

        if (alertYn !== "N") {
          if (!confirm("저장 하시겠습니까?")) {
            return false;
          }
        }

        $M.goNextPageAjax(this_page + "/save", $M.jsonArrayToForm(saveList), {method: 'POST'},
          function (result) {
            if (result.success) {
              location.reload();
              window.opener.location.reload();
            }
          }
        );
      }

      // 닫기
      function fnClose() {
        window.close();
      }

      // 행 추가
      function fnAddRows() {

        listCnt++;
        let innerHtml = '';
        const i = listCnt;

        innerHtml = fnMakeRow(i);

        $('#planTable > tbody:last').prepend(innerHtml);
        $(".calDate").datepicker();
        pageInit();
      }

      // 행 만들기 (행추가, 행 초기화 공통)
      function fnMakeRow(i, data) {
        let innerHtml = '';
        let useYn = "Y";
        let seq = 0;
        let text = "";
        let s_start_dt = workDt;
        let s_end_dt = workDt;

        if (data) {
          useYn = data.use_yn;
          seq = data.work_plan_seq;
          text = data.plan_text;
          s_start_dt = data.plan_st_dt;
          s_end_dt = data.plan_ed_dt;
        }

        innerHtml += '<tr id="tr_plan_' + i + '">';
        innerHtml += '    <th class="text-right">일정' + i + '</th>';
        innerHtml += '    <td colspan="5">';
        innerHtml += '        <input type="hidden" id="work_plan_seq_' + i + '" name="work_plan_seq_' + i + '" value="' + seq + '" >';
        innerHtml += '        <input type="hidden" id="use_yn_' + i + '" name="use_yn_' + i + '" value="' + useYn + '" >';
        innerHtml += '        <div class="form-row">';
        innerHtml += '            <div class="col-auto">';
        innerHtml += '                <div class="input-group dev_nf">';
        innerHtml += '                    <input type="text" value="' + s_start_dt + '" class="form-control border-right-0 calDate" id="s_start_' + i + '_dt" name="s_start_' + i + '_dt" dateformat="yyyy-MM-dd" alt="시작일" required>';
        innerHtml += '                </div>';
        innerHtml += '            </div>';
        innerHtml += '            <div class="col-auto">~</div>';
        innerHtml += '            <div class="col-5">';
        innerHtml += '                <div class="input-group dev_nf">';
        innerHtml += '                    <input type="text" value="' + s_end_dt + '" class="form-control border-right-0 calDate" id="s_end_' + i + '_dt" name="s_end_' + i + '_dt" dateformat="yyyy-MM-dd" alt="종료일" required>';
        innerHtml += '                </div>';
        innerHtml += '            </div>';
        innerHtml += '        </div>';
        innerHtml += '        <div class="mt5">';
        innerHtml += '            <textarea id="plan_text_' + i + '" name="plan_text_' + i + '" style="height: 100px;" maxlength="1000">' + text + '</textarea>'; // Q&A 17421 최대 글자수 제한
        innerHtml += '        </div>';
        innerHtml += '    </td>';
        innerHtml += '</tr>';
        // 버튼
        innerHtml += '<tr>'
        innerHtml += '    <td style="border: none;"></td>'
        innerHtml += '    <td style="border: none;">'
        innerHtml += '        <div class="btn-group mt5 mb5">'
        innerHtml += '            <div class="right">'
        innerHtml += '                <button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnAddRows();">추가</button>'
        innerHtml += '                <button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnRemoveRow(this, ' + i + ');">삭제</button>'
        innerHtml += '            </div>'
        innerHtml += '        </div>'
        innerHtml += '    </td>'
        innerHtml += '</tr>'

        return innerHtml;
      }

      // 행 삭제
      function fnRemoveRow(button, index) {

        // 신규 행 구분
        if ($M.getValue("work_plan_seq_" + index) == 0) {
          if (!confirm("작성한 내용을 삭제 하시겠습니까?")) {
            return false;
          }
          button.closest("tr").remove();
          $('#tr_plan_' + index).closest("tr").remove();
        } else {
          if (!confirm("작성중이던 일정은 저장됩니다.\n해당 일정을 삭제 하시겠습니까?")) {
            return false;
          }
          $M.setValue("use_yn_" + index, "N");
          goSave("N");
        }
      }

    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="title-wrap">
                <h4 id="view_date"></h4>
                <%-- [재호] Q&A 20453 : 삭제 처리 --%>
<%--                <div class="btn-group">--%>
<%--                    <div class="right">--%>
<%--                        <button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnAddRows();">--%>
<%--                            추가--%>
<%--                        </button>--%>
<%--                    </div>--%>
<%--                </div>--%>
            </div>
            <!-- 일정 목록 영역 -->
            <table class="table-border" id="planTable" style="margin-top: 5px; border: none;">
                <colgroup>
                    <col width="10%">
                    <col width="90%">
                </colgroup>
                <!-- 일정 리스트 영역 -->
                <tbody id="planList"></tbody>
            </table>
            <!-- /일정 목록 영역 -->
            <!-- 버튼 영역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
            <!-- /버튼 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>
