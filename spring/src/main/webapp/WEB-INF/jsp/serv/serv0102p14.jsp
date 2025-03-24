<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 자주쓰는 출하내역
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-22 17:14:37
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var machineMap = ${machineMap};
		var rowNum = 1;
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});

		function goMachineListChange() {
			var makerCd = $M.getValue("s_maker_cd");
			// select box 옵션 전체 삭제
			$("#s_machine_plant_seq option").remove();
			// select box option 추가
			$("#s_machine_plant_seq").append(new Option('- 전체 -', ""));

			if(machineMap.hasOwnProperty(makerCd)) {
				var machineList = machineMap[makerCd];
				for(item in machineList) {
					$("#s_machine_plant_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_plant_seq));
				}
			}
			goSearch();
		}
		
		// 장비 정보
		function fnInit() {
			var makerCd = '${inputParam.maker_cd}';
			var machinePlantSeq = '${inputParam.machine_plant_seq}';
			$("#s_machine_plant_seq option").remove();
			$("#s_machine_plant_seq").append(new Option('- 전체 -', ""));
			if(machineMap.hasOwnProperty(makerCd)) {
				var machineList = machineMap[makerCd];
				for(item in machineList) {
					if(machineList[item].machine_plant_seq == machinePlantSeq) {
						$("#s_machine_plant_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_plant_seq, '', true));
					} else {
						$("#s_machine_plant_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_plant_seq, '', false));
					}
				}
			}
			goSearch();
		}

		function goSearch() {
			var params = {
				"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : "GET"},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGrid, result.list);
						rowNum = $M.nvl(result.listSize, 1);
					};
				}
			);
		}

		// 행삭제
		function fnRemove() {
			var removeData = AUIGrid.getCheckedRowItems(auiGrid);
			if(removeData.length == 0) {
				alert("적용할 데이터를 체크해주세요.");
				return;
			}

			for(var i in removeData) {
				var isRemoved = AUIGrid.isRemovedById(auiGrid, removeData[i].item._$uid);
				if(isRemoved == false) {
					AUIGrid.removeRow(auiGrid, removeData[i].rowIndex);
					AUIGrid.update(auiGrid);
				} else {
					AUIGrid.restoreSoftRows(auiGrid, removeData[i].rowIndex);
					AUIGrid.update(auiGrid);
				}
			}
		}

		// 적용
		function goApplyInfo() {
			var checkedData = AUIGrid.getCheckedRowItems(auiGrid);
			if(checkedData.length == 0) {
				alert("적용할 데이터를 체크해주세요.");
				return;
			}

			try {
				opener.${inputParam.parent_js_name}(checkedData);
				window.close();
			} catch(e) {
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
		}

		// 행추가
		function fnAdd() {

			var gridData = AUIGrid.getGridData(auiGrid);
			var length = gridData.length - 1;
			var sortNo = gridData[length].sort_no;
			var nextSortNo = $M.toNum(sortNo) + 1;
			if(fnCheckGridEmpty()) {
				var item = new Object();
				item.out_text = "";
				item.sort_no = nextSortNo;
				item.machine_plant_seq = $M.getValue("s_machine_plant_seq");
				item.use_yn = "Y";
				item.out_check_bookmark_seq = "";
				item.row_num = rowNum;

				AUIGrid.addRow(auiGrid, item, 'last');
			};

			rowNum++;
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["out_text", "sort_no"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 저장
		function goSave() {
			var frm = $M.toValueForm(document.main_form);
			var gridForm = fnChangeGridDataToForm(auiGrid, 'use_yn');

			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
			console.log(gridForm);

			$M.goNextPageAjaxSave(this_page + "/save", gridForm, {method : "POST"},
				function(result) {
					if(result.success) {
						alert("저장이 완료하였습니다.");
						location.reload();
					}
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showStateColumn : true,
				editable : true
			};
			var columnLayout = [
				{
					headerText : "출하내역",
					dataField : "out_text",
					style : "aui-left aui-editable",
					width : "90%",
				},
				{
					headerText : "정렬순서",
					dataField : "sort_no",
					style : "aui-center aui-editable",
					width : "10%"
				},
				{
					headerText : "장비번호",
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					visible : false
				},
				{
					headerText : "행번호",
					dataField : "row_num",
					visible : false
				},
				{
					headerText : "자주쓰는번호",
					dataField : "out_check_bookmark_seq",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGrid").resize();
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
			<!-- 의견추가내역 -->
			<div class="title-wrap">
				<div class="left">
					<select class="form-control width100px mr5" id="s_maker_cd" name="s_maker_cd" onchange="javascript:goMachineListChange();" >
						<option value="">- 전체 -</option>
						<c:forEach items="${codeMap['MAKER']}" var="item">
							<option value="${item.code_value}" ${item.code_value == inputParam.maker_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
						</c:forEach>
					</select>
					<select class="form-control width100px" id="s_machine_plant_seq" name="s_machine_plant_seq" onchange="javascript:goSearch();">
					</select>
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
			<!-- /의견추가내역 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>