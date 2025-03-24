<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > null > null > 도움말
-- 작성자 : 임예린
-- 최초 작성일 : 2021-07-28 15:46:58
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var seqList;
		var lastSortNum;
		$(document).ready(function() {
			lastSortNum=0;
			createAUIGrid();
			goSearch();
		});
		
		//조회
		function goSearch() {
			var param = {
					"s_menu_seq" : ${bean.menu_seq }
			}; 
			
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						var gridData = AUIGrid.getGridData(auiGrid);
						var item = AUIGrid.getItemByRowIndex(auiGrid, gridData.length-1);
						lastSortNum = item.sort_no;
						seqList = result.seq_list;
					} 
				}
			);
		}
			
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "menu_help_seq",
				rowHeight	: 150,
				showRowNumColumn: true,
				editable: true,
			};
			var columnLayout = [
				{ 
					dataField : "menu_help_seq",
					visible : false
				},
				{
					headerText : "이미지",
					dataField : "help_file_seq",
					editable: false,
					width : 200,
					renderer : {
						type : "ImageRenderer",
						imgHeight : 150, // 이미지 높이, 지정하지 않으면 rowHeight에 맞게 자동 조절되지만 빠른 렌더링을 위해 설정을 추천합니다.
						altField : "file_name" // alt(title) 속성에 삽입될 필드명, 툴팁으로 출력됨
					}
				},
				{ 
					dataField : "file_size",
					visible : false
				},
				{ 
					dataField : "file_ext",
					visible : false
				},
				{ 
					dataField : "file_seq",
					visible : false
				},
				{ 
					dataField : "file_name",
					visible : false
				},
				{ 
					headerText : "파일", 
					dataField : "origin_file_name",
					editable: false,
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
						if(item.file_seq == 0) {
							return '<button type="button" class="btn btn-default" style="width: 90%" onclick="javascript:goUploadImg(' + rowIndex + ');">이미지등록</button>';
						} else {
							var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:goModifyImg(' + rowIndex + ');">' + value + '</span>' + '</div>';
							return template;
						}
					}
				},
				{
					headerText : "정렬", 
					dataField : "sort_no",
					dataType : "numeric",
					width : "180",
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true,
						allowNegative : false, 
						allowPoint : false,
						validator : function(oldValue, newValue, item, dataField, fromClipboard) {
							//0보다 큰 수만 입력
						    var isValid = false;
						    var numVal = Number(newValue);
						    if(numVal > 0) {
						    	isValid = true;
						    }
						    return { "validate" : isValid, "message"  : "0 보다 큰 수를 입력하세요." };
						}
					}
				},
				{
					headerText: "삭제여부",
					dataField: "help_del_yn",
					visible: false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					editable: false,
					width : "80",
					minWidth : "70",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item.menu_help_seq);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
							}
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
				//정렬 순서 빈칸 체크
				var gridData = AUIGrid.getGridData(auiGrid);
				if(event.item["sort_no"] == null || event.item["sort_no"] == '') {
					alert("정렬 순서는 비워둘 수 없습니다.");
					AUIGrid.setCellValue(auiGrid, event.rowIndex, "sort_no", ++lastSortNum);
					return;
				}
				//정렬 순서 변경 시 중복체크
				for(var i=0 ; i<gridData.length ; i++) {
					if(gridData[i].menu_help_seq == event.item["menu_help_seq"]) {
						continue;
					}
					if(gridData[i].sort_no == event.item["sort_no"]) {
						alert("정렬 순서는 중복될 수 없습니다.");
						AUIGrid.setCellValue(auiGrid, event.rowIndex, "sort_no", ++lastSortNum);
						break;
					}
				}
			}),
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var tempArr = [];
				// 이미지 클릭 시
				if(event.dataField == "help_file_seq") {
					// help_file_seq 리스트 가공
					for(var seq in seqList) {
						if(seq == event.item["menu_help_seq"]) {
							tempArr = seqList[seq];
						}
					}
					var itemArr = [];
					// 라이브러리 형식으로 가공
					for(var sms_file in tempArr[0] ) {
						var smsArr = {"src" : tempArr[0][sms_file]};
						itemArr.push(smsArr);
					}
					if(itemArr == "") {
						alert("이미지가 존재하지 않습니다.");
						return false;
					}
					// 이미지 미리보기 라이브러리
					$.magnificPopup.open({
						closeOnContentClick: true,
						closeBtnInside: true,
						fixedContentPos: true,
						mainClass: 'mfp-no-margins mfp-with-zoom',
					    items:itemArr
						,
					    gallery: {
					      enabled: true,
			              navigateByImgClick: true,
					    },
					    image: {
							verticalFit: true,
							tError: '이미지를 불러오는데 실패 하였습니다.'
						},
					    type: 'image'
					});
					 $(".mfp-close").attr('id','magnific-btn-close');
			       	 $("#magnific-btn-close").css({
			            display: "block"
			        });
				}
			});
		}
		
		// 행 추가
		function fnAddSec() {
			var item = new Object();

			item.menu_help_seq = 0;
			item.help_file_seq = '/static/img/no-image.png';
			item.file_seq = 0;
			item.origin_file_name = '';
			item.sort_no = ++lastSortNum;
			item.help_del_yn = 'Y';

			AUIGrid.addRow(auiGrid, item, "last");
		}
		
		// 파일 업로드
		function goUploadImg(rowIndex) {
			if (rowIndex != undefined) {
				$M.setValue("row_index", rowIndex);
				openFileUploadPanel("fnSetHelpImage", 'upload_type=HELP&file_type=img&max_width=1920&max_height=1080&max_size=2048');
			} else {
				openFileUploadPanel("fnSetImage", 'upload_type=HELP&file_type=img&max_width=1920&max_height=1080&max_size=2048');
			}
		}
		
		//파일 수정 업로드
		function goModifyImg(rowIndex) {
			var gridData = AUIGrid.getGridData(auiGrid);
			var item;
			if (rowIndex != undefined) {
				$M.setValue("row_index", rowIndex);
				item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				openFileUploadPanel("fnSetHelpImage", 'upload_type=HELP&file_type=img&max_width=1920&max_height=1080&max_size=2048&file_seq='+item.file_seq);
			} else {
				item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				openFileUploadPanel("fnSetImage", 'upload_type=HELP&file_type=img&max_width=1920&max_height=1080&max_size=2048&file_seq='+item.file_seq);
			}
		}
		
		// 파일업로드 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result !== null && result.file_seq !== null) {
				$M.setValue("help_file_seq", "/file/" + result.file_seq);
			}
		}
		
		// 이미지 값 Setting
		function fnSetHelpImage(result) {
			if (result !== null && result.file_seq !== null) {
				AUIGrid.updateRow(auiGrid, {help_file_seq : "/file/" + result.file_seq}, $M.getValue("row_index"));
				AUIGrid.updateRow(auiGrid, {file_seq : result.file_seq}, $M.getValue("row_index"));
				AUIGrid.updateRow(auiGrid, {origin_file_name : result.file_name}, $M.getValue("row_index"));
				AUIGrid.updateRow(auiGrid, {file_name : result.file_name}, $M.getValue("row_index"));
				AUIGrid.updateRow(auiGrid, {file_size : result.file_size}, $M.getValue("row_index"));
				AUIGrid.updateRow(auiGrid, {file_ext : result.file_ext}, $M.getValue("row_index"));
			}
		}
		
		function goSave() {
			// 수정된 행 아이템들(배열)
			var addedRowItems = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
			var editedRowItems = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
			var removedRowItems = AUIGrid.getRemovedItems(auiGrid); //삭제내역
			var gridData = AUIGrid.getGridData(auiGrid);
			
			//예외처리
			var frm = document.main_form;
	     	if($M.validation(frm) == false) {
	     		return;
	     	}
			if (addedRowItems.length == 0 && editedRowItems.length == 0 && removedRowItems == 0) {
				alert("변경된 부분이 없습니다.");
				return;
			}
			
			var menuHelpSeq = [];
			var fileSeq = [];
			var fileSize = [];
			var fileExt = [];
			var fileName = [];
			var originFileName = [];
			var sortNo = [];
			var bizCmdArr = [];
			
			for (var i = 0; i < addedRowItems.length; i++) {
				menuHelpSeq.push(addedRowItems[i].menu_help_seq);
				if(addedRowItems[i].file_seq == null || addedRowItems[i].file_seq == '' || addedRowItems[i].file_seq == 0) {
					alert("이미지 파일을 업로드 해 주세요.");
					return;
				} else {
					fileSeq.push(addedRowItems[i].file_seq);
				}
				fileSize.push(addedRowItems[i].file_size);
				fileExt.push(addedRowItems[i].file_ext);
				fileName.push(addedRowItems[i].file_name);
				originFileName.push(addedRowItems[i].origin_file_name);
				sortNo.push(addedRowItems[i].sort_no);
				bizCmdArr.push("C");
			}
			
			for (var i = 0; i < editedRowItems.length; i++) {
				menuHelpSeq.push(editedRowItems[i].menu_help_seq);
				if(editedRowItems[i].file_seq == null || editedRowItems[i].file_seq == '' || editedRowItems[i].file_seq == 0) {
					alert("이미지 파일을 업로드 해 주세요.");
					return;
				} else {
					fileSeq.push(editedRowItems[i].file_seq);
				}
				fileSize.push(editedRowItems[i].file_size);
				fileExt.push(editedRowItems[i].file_ext);
				fileName.push(editedRowItems[i].file_name);
				originFileName.push(editedRowItems[i].origin_file_name);
				sortNo.push(editedRowItems[i].sort_no);
				bizCmdArr.push("U");
			}
			
			for (var i = 0; i < removedRowItems.length; i++) {
				menuHelpSeq.push(removedRowItems[i].menu_help_seq);
				fileSeq.push(removedRowItems[i].file_seq);
				fileSize.push(removedRowItems[i].file_size);
				fileExt.push(removedRowItems[i].file_ext);
				fileName.push(removedRowItems[i].file_name);
				originFileName.push(removedRowItems[i].origin_file_name);
				sortNo.push("0");
				bizCmdArr.push("D");
			}
			
			var param = {
					menu_help_seq_str : $M.getArrStr(menuHelpSeq),
					file_seq_str : $M.getArrStr(fileSeq),
					file_size_str : $M.getArrStr(fileSize),
					file_ext_str : $M.getArrStr(fileExt),
					file_name_str : $M.getArrStr(fileName),
					origin_file_name_str : $M.getArrStr(originFileName),
					sort_no_str : $M.getArrStr(sortNo),
					cmd_str : $M.getArrStr(bizCmdArr),
					menu_seq : ${bean.menu_seq},
					upload_type : "HELP",
					file_type : "img"
			}
			
			$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), { method : "POST"}, 
				function() {
					fnClose();
				}
			);
		}

		//팝업 끄기
		function fnClose() {
			if(window.opener != null && !window.opener.closed){
				window.opener.location.reload();
			}
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
        <div class="content-wrap" style="padding-bottom:0px;">	  
<!-- 도움말이미지목록 -->
			<div class="title-wrap">
                <h4 class="primary">도움말 관리 (${bean.menu_name })</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 465px;"></div>
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
<!-- /도움말이미지목록 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>