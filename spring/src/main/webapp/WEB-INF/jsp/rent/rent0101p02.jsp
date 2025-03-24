<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 렌탈신청현황 > null > 렌탈어태치먼트
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		
		var auiGridPopup;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			if ("${inputParam.rental_machine_no}" == "") {
				location.reload();	
			};
			goSearch();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				<c:if test="${inputParam.apply_yn ne 'N'}">
				// 체크박스 표시 설정
				showRowCheckColumn : true,
				// 전체 체크박스 표시 설정
				showRowAllCheckBox : true,

				// 전체 선택 체크박스가 독립적인 역할을 할지 여부
				independentAllCheckBox : true,
				</c:if>
				rowIdField : "_$uid",
				showRowNumColumn: true,
						
			};
			var columnLayout = [
				{ 
					headerText : "관리번호", 
					dataField : "rental_attach_no", 
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "상태", 
					dataField : "rental_status_name",
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "고객", 
					dataField : "cust_name",
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "장비모델명", 
					dataField : "machine_name",
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no",
					width : "15%", 
					style : "aui-center"
				},
				{
					headerText : "매입처", 
					dataField : "client_name", 
					width : "10%", 
					visible : false,
					style : "aui-center"
				},
				{ 
					headerText : "어태치먼트명", 
					dataField : "attach_name",  
					width : "8%", 
					style : "aui-left"
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "일련번호", 
					dataField : "product_no", 
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "매입일자", 
					dataField : "buy_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "매입가격", 
					dataField : "buy_price", 
					width : "7%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "최종가액", 
					dataField : "attach_final_price",
					width : "7%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "렌탈매출", 
					dataField : "attach_sales",
					width : "7%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "최소판가", 
					dataField : "min_sale_price",
					width : "7%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "관리센터", 
					dataField : "mng_org_name",
					width : "5%", 
					style : "aui-center"
				},
				{
					dataField : "rental_machine_no", // 삭제 후 다시 추가 가능용
					visible : false
				},
				{
					dataField : "aui_status_cd",
					visible : false
				},
				{
					dataField : "cost_yn",
					visible : false
				},
				{
					dataField : "base_yn",
					visible : false
				}
			];
			
			auiGridPopup = AUIGrid.create("#auiGridPopup", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGridPopup, 7);
			AUIGrid.setGridData(auiGridPopup, []);
			$("#auiGridPopup").resize();
			
			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGridPopup, "rowAllChkClick", function( event ) {
				if(event.checked) {
					var uniqueValues = AUIGrid.getGridData(auiGridPopup);
					var list = [];
					for (var i = 0; i < uniqueValues.length; ++i) {
						console.log(uniqueValues[i]);
						if (uniqueValues[i].aui_status_cd != "C") {
							list.push(uniqueValues[i].rental_attach_no);
						}
					}
					AUIGrid.setCheckedRowsByValue(event.pid, "rental_attach_no", list);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "rental_attach_no", []);
				}
			});
			AUIGrid.bind(auiGridPopup, "rowCheckClick", function( event ) {
				if(event.item.aui_status_cd == "C" || (event.item.rental_machine_no != "" && event.item.rental_machine_no != "${inputParam.rental_machine_no}")) {
					alert(event.item.rental_status_name+"인 어태치먼트입니다.");
					AUIGrid.addUncheckedRowsByValue(auiGridPopup, "rental_attach_no", event.item.rental_attach_no);
					return;
				}
				
				/* 동일한 부품 중복 적용 가능이 Y 가 아니면 */
				<c:if test="${inputParam.is_same_apply_yn ne 'Y'}">
				var list = AUIGrid.getCheckedRowItemsAll(auiGridPopup);
				for(var i = 0; i < list.length; i++) {
					if(event.item.rental_attach_no != list[i].rental_attach_no && event.item.part_no == list[i].part_no) {
						alert("동일한 부품번호의 어태치먼트를 동시에 선택할 수 없습니다.");
						AUIGrid.addUncheckedRowsByValue(auiGridPopup, "rental_attach_no", event.item.rental_attach_no);
						return;
					}
				}
				</c:if>
				
			});
		}
		
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_client_name", "s_attach_name", "s_part_no", "s_product_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
	
		function goSearch() {
			var param = {
				s_client_name : $M.getValue("s_client_name"),
				s_attach_name : $M.getValue("s_attach_name"),
				s_part_no : $M.getValue("s_part_no"),
				s_product_no : $M.getValue("s_product_no"),
				s_mng_org_code : $M.getValue("s_mng_org_code"),
				s_sort_key : "part_name",
				s_own_org_code : "${inputParam.own_org_code}",
				s_rental_machine_no : "${inputParam.rental_machine_no}",
				s_not_rental_attach_no_str : "${inputParam.not_rental_attach_no}",
				s_sort_method : "desc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGridPopup, result.list);
					};
				}
			)
		}
  	
		// 체크 후 적용
        function fnApplyChecked() {
			console.log(opener.auiGrid);
      		var items = AUIGrid.getCheckedRowItemsAll(auiGridPopup);
      		if (items.length == 0) {
      			alert("체크 후 적용하세요.");
      			return false;
      		}
      		try {
    			for (var i = 0; i < items.length; i++ ) {
    				var rowItems = opener.AUIGrid.getItemsByValue(opener.auiGrid, "rental_attach_no", items[i].rental_attach_no);
    				console.log(rowItems);
    				if (rowItems.length != 0){
    					 alert("어태치먼트명을 다시 확인하세요.\n["+items[i].attach_name+"]은 이미 입력한 어태치먼트명입니다.");
    					 return false;					 
    				}
    			}
				opener.${inputParam.parent_js_name}(items);
				window.close(); 
			} catch(e) {
				console.log(e);
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
        }

  	    // 닫기
        function fnClose() {
    	    window.close(); 
        }
	
	</script>
</head>
<body   class="bg-white" >
<input type="hidden" id="s_own_org_code" name="s_own_org_code" value="${inputParam.own_org_code}"> <!-- 소유센터 조건 추가해서 조회해야할때 ex 센터 이동 -->
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>
				<div class="title-wrap">
					<h4>어태치먼트 추가</h4>				
				</div>
<!-- 검색영역 -->					
				<div class="search-wrap mt5">				
					<table class="table table-fixed">
						<colgroup>
							<col width="50px">
							<col width="90px">		
							<col width="80px">
							<col width="90px">		
							<col width="50px">
							<col width="90px">	
							<col width="60px">
							<col width="90px">		
							<col width="60px">
							<col width="90px">		
							<col width="45px">
							<col width="90px">				
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>매입처</th>
								<td>
									<input type="text" class="form-control" id="s_client_name" name="s_client_name">
								</td>
								<th>어태치먼트명</th>
								<td>
									<input type="text" class="form-control" id="s_attach_name" name="s_attach_name">
								</td>
								<th>부품번호</th>
								<td>
									<input type="text" class="form-control" id="s_part_no" name="s_part_no">
								</td>
								<th>일련번호</th>
								<td>
									<input type="text" class="form-control" id="s_product_no" name="s_product_no">
								</td>
								<c:if test="${not empty inputParam.own_org_code }">
								<th>소유센터</th>
								<td>
									<select class="form-control" name="s_own_org_code"
									<c:if test="${not empty inputParam.own_org_code}">readonly="readonly"</c:if>
									>
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}"
											<c:if test="${item.org_code eq inputParam.own_org_code}">selected</c:if>
											>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								</c:if>
								<c:if test="${empty inputParam.own_org_code }">
									<th>관리센터</th>
									<td>
									<select class="form-control" name="s_mng_org_code" <c:if test="${not empty inputParam.mng_org_code}">readonly="readonly"</c:if>>
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}" <c:if test="${item.org_code eq inputParam.mng_org_code}">selected</c:if>>${item.org_name}</option>
										</c:forEach>
									</select>
									</td>
								</c:if>
								<th>상태</th>
								<td>
									<select class="form-control" name="s_rental_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['RENTAL_STATUS']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()" >조회</button>
								</td>					
							</tr>						
						</tbody>
					</table>					
				</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<c:if test="${inputParam.apply_yn ne 'N'}">
							<button type="button" class="btn btn-default" onclick="javascript:fnApplyChecked();" ><i class="material-iconsdone text-default"></i> 체크 후 적용</button>
							</c:if>
						</div>
					</div>
				</div>
<!-- /조회결과 -->
				<div style="margin-top: 5px; height: 300px;" id="auiGridPopup" ></div>
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>							
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:fnClose();"  >닫기</button>
					</div>
				</div>
			</div>			
        </div>
    </div>
<!-- /팝업 -->
</body>
</html>