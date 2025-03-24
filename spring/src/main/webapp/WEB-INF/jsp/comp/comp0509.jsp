<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 장비연관팝업 > MS모델조회 > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-21 17:23:25
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();

			// 단일 선택 시 적용 버튼 숨김
			if ('${inputParam.multi_yn}' == 'N') {
				$("#_goApply").css({
		            display: "none"
		        });
			}

			const machineName = "${inputParam.s_ms_mch_name}";
			if (machineName != "") {
				$M.setValue("s_ms_mch_name", machineName);
				goSearch();
			}
		})

		// 조회
		function goSearch() {

			const param = {
				"s_ms_mch_name" : $M.getValue("s_ms_mch_name"),
				"s_ms_maker_cd" : $M.getValue("s_ms_maker_cd"),
				"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		}

		// 해당 메이커의 기종 조회
		function goSearchMachineTypeByMaker(makerCd) {
			$("#s_ms_machine_type_cd").empty();

			const param = {
				"s_ms_maker_cd" : $M.getValue("s_ms_maker_cd"),
			};

			if (makerCd == "") {
				let template = "<option value=''>- 전체 -</option>";
				const list = ${codeMapJsonObj.MS_MACHINE_TYPE};
				list.forEach(data => {
	    			template += "<option value='" + data.code_value + "'>" + data.code_name + "</option>";
				});
				$("#s_ms_machine_type_cd").append(template);
				return false;
			}

			$M.goNextPageAjax(this_page + "/" + makerCd, $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success) {
						const listData = result.list;
	    				let template = "<option value=''>- 전체 -</option>";
						listData.forEach(map => {
			    			template += "<option value='" + map.ms_machine_type_cd + "'>" + map.ms_machine_type_name + "</option>";
						});
	    				$("#s_ms_machine_type_cd").append(template);
					}
				}
			);
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			const field = ["s_ms_mch_name", "s_ms_maker_cd", "s_sort_key", "s_sort_method"];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}

		// 그리드 생성
		function createAUIGrid() {
			let gridPros = {
				rowIdField : "_$uid",
				wrapSelectionMove : false, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				showRowNumColumn: true,
				editable : false,
			};

			if ('${inputParam.multi_yn}' == 'Y') {
				gridPros.showRowCheckColumn = true; // 체크박스 출력 여부
				gridPros.showRowAllCheckBox = true; // 전체선택 체크박스 표시 여부
			}

			const columnLayout = [
				{
					headerText : "메이커",
					dataField : "ms_maker_name",
					width : "25%",
					style : "aui-center",
				},
				{
					dataField: "ms_maker_cd",
					visible: false
				},
				{
					headerText : "모델명",
					dataField : "ms_mch_name",
					width : "25%",
					style : "aui-center",
				},
				{
					dataField : "ms_mch_plant_seq",
					visible : false
				},
				{
					headerText : "기종",
					dataField : "ms_machine_type_name",
					width : "25%",
					style : "aui-center"
				},
				{
					dataField: "s_mms_machine_type_cd",
					visible: false
				},
				{
					headerText : "규격",
					dataField : "ms_machine_sub_type_name",
					style : "aui-center"
				},
				{
					dataField : "ms_machine_sub_type_cd",
					visible : false
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if ('${inputParam.multi_yn}' == 'N') {
					// Row행 클릭 시 반영
					try {
						opener.${inputParam.parent_js_name}(event.item);
						window.close();
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
				} else {
					// 다중선택시 셀클릭 이벤트 바인딩
					AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
				}
			});
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			const item = event.item;
			const rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // get 'rowIdField'
			const rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if (AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
			}
		}

		// 적용 (다중체크 시)
		function goApply() {
			const itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			console.log(itemArr);
			try {
				opener.${inputParam.parent_js_name}(itemArr);
				window.close();
			} catch(e) {
				alert('호출 페이지가 닫혔거나, ${inputParam.parent_js_name}(row) 함수가 구현되어있지 않습니다.');
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
						<col width="70px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>모델명</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_ms_mch_name" name="s_ms_mch_name">
								</div>
							</td>
							<th>메이커</th>
							<td>
								<select class="form-control" id="s_ms_maker_cd" name="s_ms_maker_cd" onchange="goSearchMachineTypeByMaker(this.value);" >
									<option value="">- 전체 -</option>
									<c:forEach items="${msMakerList}" var="item">
										<option value="${item.code_value}" ${item.code_value == inputParam.s_ms_maker_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th>기종</th>
							<td>
								<select class="form-control" id="s_ms_machine_type_cd" name="s_ms_machine_type_cd">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['MS_MACHINE_TYPE']}" var="item">
										<option value="${item.code_value}" ${item.code_value == inputParam.s_ms_machine_type_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
									</c:forEach> 
								</select>
							</td>
							<td class="pl10">
								<button type="button" class="btn btn-important" style="width: 70px;" onclick="goSearch();">조회</button>
							</td>
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
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
				<!-- /검색결과 -->
	        </div>
	    </div>
	</div>
<!-- /팝업 -->
</form>
</body>
</html>