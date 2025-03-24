<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 장비연관팝업 > 장비연관팝업 > null > 모델조회
-- 작성자 : 강명지
-- 수정자 : 김태훈(멀티 선택 추가, 전체 선택 오류 수정, 가격미포함 조회여부 체크)
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			// readonly
			fnSetReadOnly('${inputParam.machineReadOnlyField}'.split(','));
			
			createAUIGrid();
			// 단일 선택 시 적용 버튼 숨김
			if('${inputParam.multi_yn}' == 'N') {
				$("#_goApply").css({
		            display: "none"
		        });
			}
			var machineNm = "${inputParam.s_machine_name}";
			if (machineNm != "") {
				$M.setValue("s_machine_name", machineNm);
				goSearch();
			}
		});
		
		function goSearch(){
			var s_price_present_yn = "${inputParam.s_price_present_yn}";
			var s_rental_base_yn = "${inputParam.s_rental_base_yn}";
			var s_machine_order_yn = "${inputParam.s_machine_order_yn}";
			var param = {
					"s_sort_key" : "maker_cd asc, a.machine_name",
					"s_sort_method" : "asc",
					"s_machine_name" : $M.getValue("s_machine_name"),
					"s_maker_cd" : $M.getValue("s_maker_cd"),
					"s_sale_yn" : $M.getValue("s_sale_yn"),
					"s_machine_type_cd" : $M.getValue("s_machine_type_cd"),
					"s_rental_base_yn" : s_rental_base_yn,
					"s_price_present_yn" : s_price_present_yn, // 장비가격 포함여부(계약품의서에서 가격없는 장비 제외용)
					"s_machine_order_yn" : s_machine_order_yn,
					"s_rental_consult_yn" : "${inputParam.s_rental_consult_yn}",
					"s_own_org_code" : "${inputParam.s_own_org_code}"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					};
				}
			);
		}
		
		function goSearchMachineTypeByMaker(maker) {
			$("#s_machine_type_cd").empty();
			var param = {
					"s_maker_cd" : $M.getValue("s_maker_cd"),
			};
			if (maker == "") {
				var template = "<option value=''>- 전체 -</option>";
				var list = ${codeMapJsonObj.MACHINE_TYPE}
				for(var i=0; i<list.length; i++){
	    			template += "<option value='"+list[i].code_value+"'>"+list[i].code_name+"</option>";
	    		};
				$("#s_machine_type_cd").append(template);
				return false;
			}
			$M.goNextPageAjax(this_page + "/" + maker, $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var listData = result.list;
	    				var template = "<option value=''>- 전체 -</option>";
	    				for(var i=0; i<listData.length; i++){
			    			template += "<option value='"+listData[i].machine_type_cd+"'>"+listData[i].machine_type_name+"</option>";
			    		}
	    				$("#s_machine_type_cd").append(template);
			    		
					};
				}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_machine_name", "s_maker_cd", "s_sale_yn", "s_sort_key", "s_sort_method"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function createAUIGrid() {
			var gridPros;
			if('${inputParam.multi_yn}' == 'Y') {
				gridPros = {
					rowIdField : "_$uid",
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					//체크박스 출력 여부
					showRowCheckColumn : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
					// rowNumber 
					showRowNumColumn: true,
					editable : false,
					rowStyleFunction : function(rowIndex, item) {
						if(item.sale_yn == "N") {
							return "aui-color-red";
						}
					}
				};
			} else {
				gridPros = {
					rowIdField : "_$uid",
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					// rowNumber 
					showRowNumColumn: true,
					editable : false,
					rowStyleFunction : function(rowIndex, item) {
						if(item.sale_yn == "N") {
							return "aui-color-red";
						}
					}
				};
			}
			
			var columnLayout = [
				{
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "25%", 
					style : "aui-center",
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "25%", 
					style : "aui-center",
				},
				{
					headerText : "기종", 
					dataField : "machine_type_name", 
					width : "25%", 
					style : "aui-center"
				},
				{
					headerText : "규격", 
					dataField : "machine_sub_type_name", 
					style : "aui-center"
				},
				{
					dataField : "sale_yn", 
					visible : false
				},
				{
					dataField : "machine_plant_seq", 
					visible : false
				},
				{
					dataField : "motor_type",
					visible : false
				},
				{
					dataField : "motor_type_2",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if('${inputParam.multi_yn}' == 'N'){
					// Row행 클릭 시 반영
					try{
						opener.${inputParam.parent_js_name}(event.item);
						if("Y" != "${inputParam.part_comm_yn}"){
							window.close();
						}
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
				} else {
					// 다중선택시 셀클릭 이벤트 바인딩
					AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
				}
				
			});	
			$("#auiGrid").resize();
		}
		
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
		
		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			var item = event.item, rowIdField, rowId;
			rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if(AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
			}
		};
		
		//적용
		function goApply() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			console.log(itemArr);
			opener.${inputParam.parent_js_name}(itemArr);
			window.close();
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
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="50px">
						<col width="100px">
						<col width="50px">
						<col width="100px">
						<col width="50px">
						<col width="100px">
						<col width="50px">
						<col width="100px">
						<col width="50px">
					</colgroup>
					<tbody>
						<tr>
							<th>모델명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
								</div>
							</td>
							<th>메이커</th>
							<td>
								<select class="form-control" id="s_maker_cd" name="s_maker_cd" onchange="javascript:goSearchMachineTypeByMaker(this.value);" >
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['MAKER']}" var="item">
									  <c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
											<option value="${item.code_value}" ${item.code_value == inputParam.s_maker_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
									 </c:if>
									</c:forEach>
								</select>
							</td>
							<th>기종</th>
							<td>
								<select class="form-control" id="s_machine_type_cd" name="s_machine_type_cd" >
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['MACHINE_TYPE']}" var="item">
									  <option value="${item.code_value}" ${item.code_value == inputParam.s_machine_type_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
									</c:forEach> 
								</select>
							</td>
							<th>구분</th>
							<td>
								<select class="form-control" id="s_sale_yn" name="s_sale_yn" >
									<option value="Y" ${inputParam.s_sale_yn == 'Y' ? 'selected="selected"' : ''}>거래정지 미포함</option>
									<option value="N" ${inputParam.s_sale_yn == 'N' ? 'selected="selected"' : ''}>거래정지 포함</option>
								</select>
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->			
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
			<div class="btn-group mt5">	
				<div class="left">	
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
<!-- /검색결과 -->
				</div>
	        </div>
	    </div>
	</div>
<!-- /팝업 -->
</form>
</body>
</html>