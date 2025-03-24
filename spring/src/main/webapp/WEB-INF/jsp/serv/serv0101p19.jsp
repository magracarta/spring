<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 보유쿠폰
-- 작성자 : 정재호
-- 최초 작성일 : 2024-01-29 00:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <style>
    .my-row-style {
      background : #CBFFD6;
      color : #000000;
    }
  </style>
  <script type="text/javascript">

    var auiGrid;
    
    // 적용 중인 쿠폰 번호
    var connectCouponStr = '${inputParam.s_connect_coupon_str}';

    $(document).ready(function () {
      // AUIGrid 생성
      createAUIGrid();
      goSearch();
    });

    $(document).scannerDetection({
      timeBeforeScanTest: 200, // wait for the next character for upto 200ms
      startChar: [120], // Prefix character for the cabled scanner (OPL6845R)
      endChar: [13], // be sure the scan is complete if key 13 (enter) is detected
      avgTimeByChar: 40, // it's not a barcode if a character takes longer than 40ms
      minLength: 3,
      onComplete: function (barcode, qty) {
        try {
          if (fnBarcodeRead) {
            fnBarcodeRead(barcode);
          }
          return false;
        } catch (e) {
          return false;
        }

      }
    });

    // 바코드 리더기로 읽은 값 setting
    function fnBarcodeRead(barcode) {
      // 엑스트라 체크박스 체크 추가
      var gridData = AUIGrid.getGridData(auiGrid);
      
      for (let i = 0; i < gridData.length; i++) {
        const data = gridData[i];
        if(data.cust_svc_coupon_no === barcode) {
          AUIGrid.addCheckedRowsByIds(auiGrid, barcode);
          AUIGrid.updateRow(auiGrid, { "connect_yn" : "Y" }, i);
        }
      }
    }

    function goSearch() {
      var params = {
        "s_machine_plant_seq": $M.getValue("s_machine_plant_seq"),
        "s_cust_no": $M.getValue("s_cust_no"),
        "s_machine_seq": $M.getValue("s_machine_seq"),
      };

      $M.goNextPageAjax(this_page + '/search', $M.toGetParam(params), {method: 'GET'},
        function (result) {
          if (result.success) {
            var connectCouponList = connectCouponStr.split("#");
            const gridData = [];
            
            // 이미 연결했던 쿠폰 표시하기 위해 connect_yn 셋팅
            for (let i = 0; i < result.list.length; i++) {
              const item = result.list[i];
              if(connectCouponList.indexOf(item.cust_svc_coupon_no) > -1) {
                item.connect_yn = 'Y';
              }
              gridData.push(item);
            }
            AUIGrid.setGridData(auiGrid, gridData);
          }
        }
      );
    }

    function goApply() {
      var connectArr = [];
      
      // 연결된 데이터만 추출
      var gridData = AUIGrid.getGridData(auiGrid);
      gridData.forEach(item => {
        if( item.connect_yn == 'Y' ) connectArr.push({'item': item}); 
      })

      if (connectArr.length == 0) {
        alert("적용할 데이터를 스캔 해주세요.");
        return;
      }
      
      try {
        opener.${inputParam.parent_js_name}(connectArr);
        window.close();
      } catch (e) {
        alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
      }
    }

    // 닫기
    function fnClose() {
      window.close();
    }

    //그리드생성
    function createAUIGrid() {
      var gridPros = {
        rowIdField: "cust_svc_coupon_no",
        showRowNumColumn: true,
        editable: false,
        rowStyleFunction : function(rowIndex, item) {
          // 연결된 쿠폰은 초록색으로 표시
          if(item.connect_yn == "Y") {
            return "my-row-style";
          }
          return "";
        },
      };
      var columnLayout = [
        {
          headerText: "쿠폰명",
          dataField: "svc_coupon_name",
        },
        {
          headerText: "쿠폰표기명",
          dataField: "svc_disp_coupon_name",
        },
        {
          headerText: "포함범위",
          dataField: "scope_text",
        },
        {
          headerText: "유효기간",
          dataField: "expiration_period",
        },
        {
          headerText: "연결 상태",
          dataField: "connect_yn",
          visible: false,
        },
        {
          headerText: "쿠폰번호",
          dataField: "cust_svc_coupon_no",
          visible: false,
        },
      ];

      auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
      AUIGrid.setGridData(auiGrid, []);
      $("#auiGrid").resize();
    }
  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
  <input type="hidden" id="s_machine_plant_seq" name="s_machine_plant_seq" value="${inputParam.s_machine_plant_seq}"/>
  <input type="hidden" id="s_cust_no" name="s_cust_no" value="${inputParam.s_cust_no}"/>
  <input type="hidden" id="s_machine_seq" name="s_machine_seq" value="${inputParam.s_machine_seq}"/>
  <!-- 팝업 -->
  <div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
      <div>
        <div class="row">
          <div class="col-12">
            <div class="title-wrap">
                <h4>보유쿠폰 목록</h4>
              <div class="right">
                <div class="text-warning">
                  ※ 고객앱 쿠폰 QR을 스캔하면 적용됩니다.
                </div>
              </div>
            </div>
            <div id="auiGrid"></div>
            <div class="btn-group mt10">
              <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                  <jsp:param name="pos" value="BOM_R"/>
                </jsp:include>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <!-- /팝업 -->
</form>
</body>
</html>