<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 부품발주관리 > null > 센터부품할당
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid(); // 메인 그리드
			fnInit();
		});
		
		function createAUIGrid() {
			// 그리드 속성 설정
			var gridPros = {
				showStateColumn : true,
				editable : "${inputParam.part_order_status_cd}" == "0" || "${inputParam.part_order_status_cd}" == ""  ? true : false,
			};
			var columnLayout = [
				{
					dataField : "preorder_no",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					dataField : "request_order_qty", // 센터 요청수량 미만으로 값 입력 불가
					visible : false
				},
				{
					dataField : "org_name",
					headerText : "센터명",
					editable : false
				}, 
				{
					dataField : "assign_qty",
					headerText : "할당수량",
					dataType : "numeric",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false, // 소수점(.) 입력 가능 설정
						validator : function(ov, nv, item, dataField) {
							if(ov != nv) {
								var newValue = parseInt(nv);
								var oldValue = parseInt(ov);
								var isValid = true;
								if (item.request_order_qty != "") {
									var requestOrderQty = parseInt(item.request_order_qty);
									var msg = "";
									// 할당수량 밑으로 지정검사 삭제(이원영파트장 지시)
									/* if (newValue < requestOrderQty) {
										isValid = false;
										msg = "할당수량("+item.request_order_qty+") 미만으로 지정할 수 없습니다."; 
									} else {
										isValid = true;
									} */
								} 
								var assignArr = AUIGrid.getColumnValues(auiGrid, "assign_qty");
								var total = assignArr.reduce(function(a, b) { 
									return (Number(a) || 0) + (Number(b) || 0); 
								}, 0);
								if (newValue > oldValue) {
									if ((newValue-oldValue)+total > ${inputParam.order_qty}) {
										msg = "전체수량("+${inputParam.order_qty}+")을 초과했습니다."
										isValid = false;
									}
								} 
								return { "validate" : isValid, "message"  : msg };
							}
						}
					},
					
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
			AUIGrid.resize(auiGrid);
		};
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
			switch(event.type) {
			case "cellEditEnd" : 
				if(event.dataField == "assign_qty") {
					console.log(event);
					var assignArr = AUIGrid.getColumnValues(auiGrid, "assign_qty");
					var total = assignArr.reduce(function(a, b) { 
						return (Number(a) || 0) + (Number(b) || 0); 
					}, 0);
					$("#assign").html(total);
				}
			}	
		};
		
		function fnInit(init) {
			if (init != null) {
				if (confirm("할당 요청한 정보 외에는 모두 0으로 초기화합니다.\n정말 초기화하시겠습니까?") == false) {
					return false;
				}
			}
			var orgList = ${list}
			var centerArr = "${inputParam.center_cd_str}".split("^");
			if (init != null){
				centerArr = "${inputParam.init_center_cd_str}".split("^");
			}
			if (centerArr == "undefined" || centerArr == "") {
				centerArr = [];
			}
			var orderQtyArr = "${inputParam.request_order_qty_str}".split("^");
			if (init != null){
				orderQtyArr = "${inputParam.init_request_order_qty_str}".split("^");
			}
			if (orderQtyArr == "undefined" || orderQtyArr == "") {
				orderQtyArr = [];
			}
			var orgArr = ${etcCenter}
			// 창고 코드와 ORG_CODE가 같다면 창고코드를 우선으로 함.(입고창고가 삼례창고로 바뀌는 현상 수정)
			for (var i = 0; i < orgList.length; ++i) {
				if (orgArr[orgList[i].code_value] != "") {
					console.log(orgArr[orgList[i].code_value]);
					orgArr[orgList[i].code_value] = orgList[i].code_name; 
				}
			}
			var pivotOrgList = [];
			var assigned = 0;
			orgList.reduce(function(res, value) {
			  if (!res[value.code_value]) {
			    res[value.org_code] = { org_code: value.code_value, org_name: value.code_name, assign_qty: "0", request_order_qty: "" };
			    pivotOrgList.push(res[value.org_code])
			  }
			  return res;
			}, {});
			var mergeCenterQty = [];
			
			for (var i = 0; i < centerArr.length; ++i){
				assigned += parseInt(orderQtyArr[i]);
				mergeCenterQty.push({org_code: centerArr[i], assign_qty: orderQtyArr[i], request_order_qty: orderQtyArr[i], org_name: orgArr[centerArr[i]]});
				for (var j = pivotOrgList.length-1; j >= 0; --j) {
					if (pivotOrgList[j].org_code == centerArr[i]) {
						pivotOrgList.splice(j, 1);
						break;
					} 
				}
			}
			Array.prototype.push.apply(mergeCenterQty, pivotOrgList);
			console.log(assigned);
			$("#assign").html(assigned);
			$("#total_cnt").html(mergeCenterQty.length);
			console.log("init grid data", mergeCenterQty);
			AUIGrid.setGridData(auiGrid, mergeCenterQty);
		}
		
		function fnSave() {
			// input이 아니라서 $M.getValue안씀
			/* if (document.getElementById('assign').innerHTML != document.getElementById('total').innerHTML) {
				alert("할당되지 않은 수량이 있습니다.");
				return false;
			} */
			var fixedCnt = 0;
			var assignCenterCdList = [];
			var assignCenterNmList = [];
			var assignQty = [];
			var assignPreorderNoList = [];
			var gridData = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < gridData.length; ++i) {
				if (gridData[i].assign_qty != "0") {
					assignCenterCdList.push(gridData[i].org_code);
					assignCenterNmList.push(gridData[i].org_name);
					assignQty.push(gridData[i].assign_qty);
					fixedCnt+=parseInt(gridData[i].assign_qty);
				}
			}
			if (fixedCnt == "0") {
				alert("할당 수량이 없습니다.");
				return false;
			}
			var buttonText = "";
			if (assignCenterNmList != []) {
				var temp = assignCenterNmList;
				if (temp.length > 1) {
					var remain = temp.length-1;
					buttonText = temp[0] + " 외 "+remain;
				} else {
					buttonText = temp[0]
				}
			} 
			
			var assignPreorderStr = "${inputParam.preorder_no_str}";
			
			var result = {
				uid : $M.getValue("uid"),
				part_no : $M.getValue("part_no"),
				seq_no : $M.getValue("seq_no"),
				org_cd_str : assignCenterCdList.join("^"),
				org_name_str : assignCenterNmList.join("^"),
				assign_qty_array : assignQty.join("^"),
				assign_preorder_str : assignPreorderStr,
				button_text : buttonText,
				fixed_cnt : fixedCnt
			}
			console.log("return result ==> ", result);
			opener.${inputParam.parent_js_name}(result);
			window.close();
		}
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="uid" value="${inputParam.uid}">
<input type="hidden" name="part_no" value="${inputParam.part_no}">
<input type="hidden" name="seq_no" value="${inputParam.seq_no}">
<input type="hidden" name="preorder_no" value="${inputParam.preorder_no_str}">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>센터부품할당</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 상단 폼테이블 -->	
			<div>
				<table class="table-border">
					<colgroup>
						<col width="">
						<col width="">
						<col width="">
					</colgroup>
					<thead>
						<tr>
							<th>부품번호</th>
							<th>부품명</th>
							<th>전체수량</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td style="text-align: center">${inputParam.part_no}</td>
							<td>${inputParam.part_name}</td>
							<td style="text-align: center">
								<div id="assign" style="display: inline-block;">0</div>
								<div style="display: inline-block;">/</div>
								<div id="total" style="display: inline-block;">${inputParam.order_qty}</div> 
							</td> <!-- 작성중 -->
						</tr>
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div> <!-- TODO 모든 센터 + 요청수량 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>	
				<div class="right">
				
					<c:if test="${inputParam.part_order_status_cd == '0' || inputParam.part_order_status_cd == ''}">
						<!-- <button type="button" class="btn btn-info" onclick="fnSave()">저장</button>
						<button type="button" class="btn btn-info" onclick="fnInit('init')">초기화</button> -->					
					</c:if>
					<button type="button" class="btn btn-info" onclick="fnClose()">닫기</button>
				</div>
			</div>
        </div>
    </div>	
</form>
</body>
</html>