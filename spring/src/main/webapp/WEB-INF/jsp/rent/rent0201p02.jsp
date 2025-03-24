<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > 판매처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
-- 아래변경사항(21.1.25 오후 7시 22분)
-- 최승희대리 요청사항 : 운영센터에서 수익배분센터로 명칭변경, 판매손익금액 배분 합계체크로직 삭제, 판매자센터 판매센터로(직접지정)
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
  <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
  <script type="text/javascript">
    // 하단 어테치먼트 그리드
    var auiGrid;

    $(document).ready(function () {
      if ("${item.sale_dt}" == "") {
        $("#_goRentalSaleCancel").css("display", "none");
        $("#_goSave").css("display", "none");
      } else {
        $("#_goRentalSale").css("display", "none");
        if ("${inputParam.attach_sale_yn}" == "Y") {
          $("#_goSave").css("display", "none");
        }
      }
      fnCalc();
      
      <!-- 어테치먼트 판매 타입 진입이 아닐 경우 노출 (렌탈 장비 판매 일 경우) -->
      <c:if test="${inputParam.attach_sale_yn ne 'Y'}">
      // 그리드 생성
      createAUIGrid();

      // 그리드 최초 초기화
      auiGridBindEventMethod();

      // 그리드 바인드 이벤트
      AUIGrid.bind(auiGrid, ["cellEditEnd", "removeRow", "addRow"], function (event) {
        auiGridBindEventMethod();
      })
      </c:if>
    });

    // 그리드 데이터 변경 시 발생 함수
    function auiGridBindEventMethod() {
      var gridData = AUIGrid.getGridData(auiGrid);
      let attachFinalPriceTotal = 0;
      let residualPriceTotal = 0;
      gridData.map(item => {
        attachFinalPriceTotal += item.g_attach_final_price;
        residualPriceTotal += item.g_residual_price;
      })

      $M.setValue("attach_rental_total_amt", attachFinalPriceTotal);
      $M.setValue("residual_price_total", residualPriceTotal);

      fnCalc();
    }

    // 어테치먼트 그리드
    function createAUIGrid() {
      var gridPros = {
        rowIdField: "_$uid",
        showRowNumColumn: true,
        showStateColumn: true,
        editable: "${item.sale_dt}" == ""
      };

      var columnLayout = [
        {
          headerText: "관리번호",
          dataField: "g_rental_attach_no",
          style: "aui-center",
          editable: false,
        },
        {
          headerText: "어테치먼트명",
          dataField: "g_attach_part_name",
          style: "aui-center",
          editable: false,
        },
        {
          headerText: "최종가액",
          dataField: "g_attach_final_price",
          dataType: "numeric",
          formatString: "#,##0",
          style: "aui-right " + ("${item.sale_dt}" == "" ? "aui-editable" : ""),
          editRenderer: {
            type: "InputEditRenderer",
            validator: (oldValue, newValue, rowItem) => {
              const reg = /^[+-]?\d*(\.?\d*)?$/;
              return {
                "validate": reg.test(newValue),
                "message": "양수, 음수만 작성 가능합니다."
              };
            },
          },
          editable: true,
        },
        {
          headerText: "잔존가",
          headerTooltip: {
            show: true,
            tooltipHtml: "매입가 - 렌탈매출"
          },
          dataField: "g_residual_price",
          dataType: "numeric",
          formatString: "#,##0",
          style: "aui-right",
          editable: false,
        },
        {
          headerText: "렌탈수익",
          dataField: "g_rental_profit_amt",
          visible: false
        },
        {
          headerText: "최소판가",
          dataField: "g_min_sale_price",
          visible: false
        },
      ];

      auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
      AUIGrid.setGridData(auiGrid, ${attachList});
      $("#auiGrid").resize();
    }

    // 어테치먼트 추가 팝업 오픈
    function fnAdd() {
      var params = {
        mng_org_code: "${inputParam.attach_mng_org_code}",
        rental_machine_no: "${inputParam.rental_machine_no}",
        apply_yn: "Y", // 추가 팝업으로 사용 여부
        is_same_apply_yn: "Y", // 동일 부품 선택 가능 여부
      };
      openRentalAttachPanel("fnSetAttach", $M.toGetParam(params));
    }

    // 어테치먼트 추가 콜백 함수
    function fnSetAttach(data) {
      let list = [];

      data.map(item => {
        list.push({
          g_rental_attach_no: item.rental_attach_no,
          g_attach_part_name: item.attach_part_name,
          g_attach_final_price: item.attach_final_price,
          g_residual_price: item.buy_price - item.attach_sales,
          g_rental_profit_amt: item.attach_sales,
          g_min_sale_price: item.min_sale_price,
        })
      })

      AUIGrid.addRow(auiGrid, list);
    }

    function goMemberInfo() {
      // s_agency_exclude_yn 값이 없으면 Default = 'Y'
      var param = {
        's_org_code': $M.getValue('s_org_code'),
        's_agency_exclude_yn': 'Y'
      };
      openSearchMemberPanel('fnSetMemberInfo', $M.toGetParam(param))
    }

    function fnSetMemberInfo(row) {
      console.log(row);
      var param = {
        reg_org_name: row.org_name,
        reg_org_code: row.org_code,
        sale_mem_no: row.mem_no,
        sale_mem_name: row.mem_name
      }
      $M.setValue(param);
    }

    function fnSetCustInfo(row) {
      console.log(row);
      var param = {
        sale_cust_no: row.cust_no,
        sale_cust_name: row.real_cust_name
      }
      $M.setValue(param);
    }

    // 판매처리
    function goRentalSale() {
      // 어태치일 시 기존 유지
      if ("${inputParam.attach_sale_yn}" == "Y") {
        $M.setValue("reg_id", $M.getValue("sale_mem_no"));
        var frm = document.main_form;
        if ($M.validation(frm) == false) {
          return;
        }
        /* var totalCenterProfit = $M.toNum($M.getValue("sale_org_profit_amt")) + $M.toNum($M.getValue("mng_org_profit_amt"));
        var saleProfit = $M.toNum($M.getValue("sale_profit_amt"));
        if (totalCenterProfit != saleProfit) {
          alert("판매손익금액을 확인 후, 센터수익을 다시 배분하여 입력하세요.\n판매손익금액의 합은 판매센터와 운영센터의 수익의 합입니다.");
          return false;
        } */
        $M.goNextPageAjaxMsg("판매처리하시겠습니까?", this_page + '/save', $M.toValueForm(frm), {method: 'POST'},
          function (result) {
            if (result.success) {
              alert("판매처리가 완료되었습니다.");
              if (opener != null) {
                opener.location.reload();
              }
              fnClose();
            }
          }
        );
      } else {
        // validation check ( 매출세금계산서 처리 할때만 체크)
        if ($M.validation(document.main_form, {field: ["sale_price", "sale_dt", "sale_cust_name", "sale_mem_name"]}) == false) {
          return;
        }

        const gridForm = getSaveGridFormData();

        // 어테치먼트가 - 잔존가 < 0 이면 알림 노출
        const rentalTotalAmt = Number($M.getValue("attach_rental_total_amt"));
        const residualPriceTotal = Number($M.getValue("residual_price_total"));

        var attachList = AUIGrid.getGridData(auiGrid);

        if (rentalTotalAmt - residualPriceTotal <= 0 && attachList.length > 0) {
          if (confirm("잔존가 보다 어테치먼트 판매가가 낮습니다.\n정말 판매 처리하시겠습니까?")) {
            $M.goNextPageAjax(this_page + '/save', gridForm, {method: 'POST'},
              function (result) {
                if (result.success) {
                  successMethod();
                }
              }
            );
          }
        } else {
          $M.goNextPageAjaxMsg("판매처리하시겠습니까?", this_page + '/save', gridForm, {method: 'POST'},
            function (result) {
              if (result.success) {
                successMethod();
              }
            }
          );
        }
      }
    }

    // 판매 처리 그리드 폼 데이터 반환
    function getSaveGridFormData() {
      var frm = $M.toValueForm(document.main_form);

      // 어테치먼트 그리드 데이터
      var concatCols = [];
      var concatList = [];
      var gridIds = [auiGrid];
      for (var i = 0; i < gridIds.length; ++i) {
        concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
        concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
      }

      var gridForm = fnGridDataToForm(concatCols, concatList);
      $M.copyForm(gridForm, frm);
      return gridForm;
    }

    // api 성공 함수
    function successMethod() {
      if (opener != null) {
        opener.location.reload();
      }

      var param = {
        "rental_machine_no": $M.getValue("rental_machine_no")
      };
      openInoutProcPanel("fnSetInout", $M.toGetParam(param));

      location.reload();
    }

    function fnSetInout() {
      // location.reload();
      fnClose();
    }

    //판매취소
    function goRentalSaleCancel() {
      if ($M.validation(document.main_form) == false) {
        return;
      }

      var formData;
      if ("${inputParam.attach_sale_yn}" == "Y") {
        formData = $M.toValueForm(document.main_form);
      } else {
        formData = getSaveGridFormData();
      }
      
      $M.goNextPageAjaxMsg("판매취소 하시겠습니까?", this_page + '/remove', formData, {method: 'POST'},
        function (result) {
          if (result.success) {
            alert("취소가 완료되었습니다.");
            if (opener != null) {
              opener.location.reload();
            }
            fnClose();
          }
        }
      );
    }

    // 저장(판매처리 이후 수정)
    function goSave() {
      var frm = document.main_form;

      // validation check ( 매출세금계산서 처리 할때만 체크)
      if ($M.validation(frm, {field: ["reg_org_code", "reg_mem_no", "sale_org_code"]}) == false) {
        return;
      }
      ;

      var params = {
        rental_machine_no: $M.getValue("rental_machine_no"),
        sale_mem_no: $M.getValue("sale_mem_no"),
        sale_org_code: $M.getValue("sale_org_code"),
        sale_org_profit_amt: $M.getValue("sale_org_profit_amt"),
        mng_org_code: $M.getValue("mng_org_code"),
        mng_org_profit_amt: $M.getValue("mng_org_profit_amt"),
      }

      $M.goNextPageAjaxModify(this_page + '/modify', $M.toGetParam(params), {method: 'POST'},
        function (result) {
          if (result.success) {
            if (opener != null) {
              opener.location.reload();
            }

            // var param = {
            // 	"rental_machine_no" : $M.getValue("rental_machine_no")
            // };
            // openInoutProcPanel("fnSetInout", $M.toGetParam(param));
          }
        }
      );
    }

    function fnCalc() {
      var sale_price = $M.getValue("sale_price");
      var min_sale_price = $M.getValue("min_sale_price");
      var attach_rental_total_amt = Number($M.getValue("attach_rental_total_amt"));
      var sale_profit_amt = sale_price - min_sale_price + attach_rental_total_amt;
      var param = {
        sale_price: sale_price,
        min_sale_price: min_sale_price,
        sale_profit_amt: sale_profit_amt
      }
      $M.setValue(param);
    }

    //닫기
    function fnClose() {
      window.close();
    }
    
    // 자동화건 - 판매센터수익 변경 이벤트
    // - 판매센터수익 음수 입력의 경우 수익배분 값 초기화
    function onChangeProfitAmt() {
      var saleOrgProfitAmt = $M.getValue('sale_org_profit_amt');
      if(+saleOrgProfitAmt < 0) {
        $M.setValue('mng_org_code', '');
        $M.setValue('mng_org_profit_amt', '0');
        $("#mng_org_code").attr("disabled", true);
        $("#mng_org_profit_amt").attr("disabled", true);
      } else {
        $("#mng_org_code").attr("disabled", false);
        $("#mng_org_profit_amt").attr("disabled", false);
      }
    }

  </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
  <c:choose>
    <c:when test="${'Y' eq inputParam.attach_sale_yn}">
      <input type="hidden" id="rental_attach_no" name="rental_attach_no" value="${item.rental_attach_no}">
    </c:when>
    <c:otherwise>
      <input type="hidden" id="rental_machine_no" name="rental_machine_no" value="${item.rental_machine_no}">
    </c:otherwise>
  </c:choose>
  <input type="hidden" id="attach_sale_yn" name="attach_sale_yn" value="${inputParam.attach_sale_yn}">
  <input type="hidden" id="residual_price_total" name="residual_price_total" value="">
  <!-- 팝업 -->
  <div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
      <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
      <!-- 판매정보 -->
      <div>
        <div class="title-wrap">
          <h4>판매정보</h4>
        </div>
        <table class="table-border mt5">
          <colgroup>
            <col width="100px">
            <col width="">
          </colgroup>
          <tbody>
          <tr>
            <th class="text-right rs">판매일자</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <c:choose>
                <c:when test="${item.sale_dt eq ''}">
                <div class="col width120px">
                  <div class="input-group">
                    <input type="text" class="form-control border-right-0 calDate rb" required="required" id="sale_dt"
                           name="sale_dt" dateformat="yyyy-MM-dd" alt="판매일자" value="${item.sale_dt}">
                  </div>
                  </c:when>
                  <c:otherwise>
                    <div class="col width100px">
                      <input type="text" class="form-control" required="required" id="sale_dt" name="sale_dt"
                             dateformat="yyyy-MM-dd" alt="판매일자" value="${item.sale_dt}" readonly="readonly">
                    </div>
                  </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right rs">판매가격</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width100px">
                  <input type="text" class="form-control text-right ${item.sale_dt eq '' ? 'rb' : ''}"
                         required="required" format="num" id="sale_price" name="sale_price" value="${item.sale_price}"
                         alt="판매가격" onchange="fnCalc()" ${item.sale_dt eq '' ? "" : "readonly='readonly'"}>
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
          </tr>
          <%-- 자동화개발 삭제 요청으로 인해 주석 처리 --%>
          <%--						<tr>--%>
          <%--							<th class="text-right">판매순익</th> <!-- 판매수익 명칭은 우선 판매 순익으로 변경합니다. / 판매가격 – 최소판가 의 값을 입력합니다. -->--%>
          <%--							<td>--%>
          <%--								<div class="form-row inline-pd widthfix">--%>
          <%--									<div class="col width100px">--%>
          <%--										<input type="text" class="form-control text-right" required="required" format="minusNum" readonly="readonly" id="sale_profit_amt" name="sale_profit_amt" value="${empty item.sale_profit_amt ? '0' : item.sale_profit_amt}" alt="판매순익">--%>
          <%--									</div>--%>
          <%--									<div class="col width16px">원</div>--%>
          <%--								</div>									--%>
          <%--							</td>--%>
          <%--						</tr>--%>
          <tr>
            <th class="text-right rs">판매자</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width200px">
                  <div class="input-group">
                    <input type="hidden" readonly="readonly" id="sale_mem_no" name="sale_mem_no"
                           value="${item.sale_mem_no}" alt="판매자 순번">
                    <input type="hidden" readonly="readonly" id="reg_org_code" name="reg_org_code"
                           value="${item.reg_org_code}" alt="판매자 부서코드">
                    <input type="text" class="form-control" readonly="readonly" id="reg_org_name" name="reg_org_name"
                           value="${item.reg_org_name}" alt="판매자 부서명" required="required" style="border-radius: 4px">
                    <input type="text" class="form-control border-right-0" readonly="readonly" id="sale_mem_name"
                           name="sale_mem_name" value="${item.sale_mem_name}" alt="판매자명" required="required"
                           style="margin-left: 5px">
                    <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMemberInfo();"><i
                      class="material-iconssearch"></i></button>
                  </div>
                </div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right">차주명</th>
            <td>
              <input type="hidden" class="form-control border-right-0" readonly="readonly" id="sale_cust_no"
                     name="sale_cust_no" value="${item.sale_cust_no}" alt="차주명">
              <c:choose>
              <c:when test="${item.sale_dt eq ''}">
              <div class="input-group width110px">
                <input type="text" class="form-control border-right-0" readonly="readonly" id="sale_cust_name"
                       name="sale_cust_name" value="${item.sale_cust_name}" alt="차주명">
                <button type="button" class="btn btn-icon btn-primary-gra"
                        onclick="javascript:openSearchCustPanel('fnSetCustInfo');"><i class="material-iconssearch"></i>
                </button>
                </c:when>
                <c:otherwise>
                <div class="form-row inline-pd widthfix">
                  <div class="col width100px">
                    <input type="text" class="form-control" readonly="readonly" id="sale_cust_name"
                           name="sale_cust_name" value="${item.sale_cust_name}" alt="차주명">
                  </div>
                  </c:otherwise>
                  </c:choose>
                </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
      <!-- /판매정보 -->
      <!-- 판매완료 손익정산 -->
      <div>
        <div class="title-wrap mt10">
          <h4>판매완료 손익정산</h4>
          <!-- 어테치먼트 판매 타입 진입이 아닐 경우 && 판매처리되지 않았을 경우 노출 -->
          <c:if test="${inputParam.attach_sale_yn ne 'Y' and item.sale_dt eq ''}">
            <div class="btn-group">
              <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                  <jsp:param name="pos" value="MID_R"/>
                </jsp:include>
              </div>
            </div>
          </c:if>
        </div>
        <table class="table-border mt5">
          <colgroup>
            <col width="100px">
            <col width="">
          </colgroup>
          <tbody>
          <tr>
            <th class="text-right">최소판가</th> <!-- 판매최소금액 명칭을 최소판가 로 변경합니다. ( 앞페이지의 최소판가 와 동일한 값입니다. ) -->
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width100px">
                  <input type="text" class="form-control text-right" readonly="readonly" format="decimal"
                         id="min_sale_price" name="min_sale_price" alt="최소판가"
                         value="${empty item.min_sale_price ? '0' : item.min_sale_price}">
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right">렌탈순익</th> <!-- 렌탈수익 명칭을 렌탈 순익으로 변경합니다. ( 앞페이지의 렌탈 금액 – 렌탈 감가 의 값을 입력합니다. ) -->
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width100px">
                  <input type="text" class="form-control text-right" readonly="readonly" format="decimal"
                         required="required" id="rental_profit_amt" name="rental_profit_amt"
                         value="${empty item.rental_profit_amt ? '0' : item.rental_profit_amt}" alt="렌탈순익">
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
          </tr>
          <!-- 어테치먼트 판매 타입 진입이 아닐 경우 노출 (렌탈 장비 판매 일 경우) -->
          <c:if test="${inputParam.attach_sale_yn ne 'Y'}">
            <tr>
              <th class="text-right">어테치먼트가</th> <!-- 추가된 어테치먼트의 합계 노출 -->
              <td>
                <div class="form-row inline-pd widthfix">
                  <div class="col width100px">
                    <input type="text" class="form-control text-right" readonly="readonly" format="decimal"
                           required="required" id="attach_rental_total_amt" name="attach_rental_total_amt" value="0"
                           alt="어테치먼트가">
                  </div>
                  <div class="col width16px">원</div>
                </div>
              </td>
            </tr>
          </c:if>
          <tr>
            <th class="text-right">판매손익금액</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width100px">
                  <input type="text" class="form-control text-right" readonly="readonly" format="decimal"
                         id="sale_profit_amt" name="sale_profit_amt"
                         value="${empty item.sale_profit_amt ? '0' : item.sale_profit_amt}" alt="판매손익금액">
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right rs">판매센터수익</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width100px">
                  <select class="form-control" id="sale_org_code" name="sale_org_code" alt="판매센터" required="required">
                    <option value="">- 선택 -</option>
                    <c:forEach var="orgitem" items="${orgCenterList}">
                      <option
                        value="${orgitem.org_code}" ${orgitem.org_code eq item.sale_org_code ? 'selected="selected"' : ''}>${orgitem.org_name}</option>
                    </c:forEach>
                  </select>
                </div>
                <div class="col width120px">
                  <%--										<input type="text" class="form-control text-right rb" format="decimal" id="sale_org_profit_amt" name="sale_org_profit_amt" value="${empty item.sale_org_profit_amt ? '0' : item.sale_org_profit_amt}" alt="판매센터수익" required="required">--%>
                  <input type="text" class="form-control text-right rb" format="minusNum" id="sale_org_profit_amt"
                         name="sale_org_profit_amt"
                         value="${empty item.sale_org_profit_amt ? '0' : item.sale_org_profit_amt}" alt="판매센터수익"
                         onchange="javascript:onChangeProfitAmt()"
                         required="required">
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
          </tr>
          <tr>
            <th class="text-right">수익배분센터</th>
            <td>
              <div class="form-row inline-pd widthfix">
                <div class="col width100px">
                  <select class="form-control" id="mng_org_code" name="mng_org_code" alt="수익배분센터" <c:if test="${item.sale_org_profit_amt < 0}">disabled</c:if>>
                    <!-- 운영센터에서 수익배분센터로 명칭변경 -->
                    <option value="">- 선택 -</option>
                    <c:forEach var="orgitem" items="${orgCenterList}">
                      <option
                        value="${orgitem.org_code}" ${orgitem.org_code eq item.mng_org_code ? 'selected="selected"' : ''}>${orgitem.org_name}</option>
                    </c:forEach>
                  </select>
                </div>
                <div class="col width120px">
                  <%--										<input type="text" class="form-control text-right" format="decimal" id="mng_org_profit_amt" name="mng_org_profit_amt" value="${empty item.mng_org_profit_amt ? '0' : item.mng_org_profit_amt}" alt="운영센터수익" required="required">--%>
                  <input type="text" class="form-control text-right" format="minusNum" id="mng_org_profit_amt"
                         name="mng_org_profit_amt"
                         value="${empty item.mng_org_profit_amt ? '0' : item.mng_org_profit_amt}" alt="운영센터수익"
                         <c:if test="${item.sale_org_profit_amt < 0}">disabled</c:if>
                         required="required">
                </div>
                <div class="col width16px">원</div>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
      <!-- /판매완료 손익정산 -->
      <!-- 어테치먼트 -->
      <!-- 어테치먼트 판매 타입 진입이 아닐 경우 노출 (렌탈 장비 판매 일 경우) -->
      <c:if test="${inputParam.attach_sale_yn ne 'Y'}">
        <div>
          <div class="title-wrap mt10">
            <h4>어테치먼트</h4>
          </div>
          <div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
        </div>
      </c:if>
      <!-- /어테치먼트 -->
      <div class="btn-group mt10">
        <div class="right">
          <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
            <jsp:param name="pos" value="BOM_R"/>
          </jsp:include>
        </div>
      </div>
    </div>
  </div>
  <!-- /팝업 -->
</form>
</body>
</html>